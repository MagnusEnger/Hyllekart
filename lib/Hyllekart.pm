package Hyllekart;
use Dancer ':syntax';
use Dancer::Plugin::Auth::Extensible;
use Dancer::Plugin::DBIC;
use Dancer::Plugin::FlashMessage;
use Dancer::Exception qw(:all);
use Crypt::SaltedHash;
use Data::Dumper; # DEBUG 

our $VERSION = '0.1';

hook 'before' => sub {

    var appname  => config->{appname};
    var min_pass => config->{min_pass};

    if ( logged_in_user ) {
        # Get the data for the logged in user
        my $user = logged_in_user;
        # Remove the password, no reason to be passing it around
        delete $user->{password};
        # Store the data in the session, so it's available to templates etc
        session user  => $user;
        session roles => user_roles;
    }

};

get '/' => sub {
    template 'index';
};

get '/login' => sub {
    template 'login';
};

get '/admin' => require_role admin => sub { 
    template 'admin';
};

get '/superadmin' => require_role superadmin => sub { 
    my @users     = rset('User')->all;
    my @libraries = rset('Library')->all;
    template 'superadmin', { 
        'users'     => \@users,
        'libraries' => \@libraries,
    };
};

get '/libraries/add' => require_role superadmin => sub { 
    template 'libraries_add';
};

post '/libraries/add' => require_role superadmin => sub {

    my $name = param 'name';
    try {
        my $new_library = rset('Library')->create({
            name  => $name,
        });
        flash info => 'A new library was added!';
        redirect '/superadmin';
    } catch {
        flash error => "Oops, we got an error:<br />$_";
        error "$_";
        template 'libraries_add', { name => $name };
    };

};

get '/libraries/edit/:id' => require_role superadmin => sub {

    my $id = param 'id';
    my $library = rset('Library')->find( $id );
    template 'libraries_edit', { library => $library };

};

post '/libraries/edit' => require_role superadmin => sub {

    my $id   = param 'id';
    my $name = param 'name';
    my $library = rset('Library')->find( $id );
    try {
        $library->set_column('name', $name);
        $library->update;
        flash info => 'A library was updated!';
        redirect '/superadmin';
    } catch {
        flash error => "Oops, we got an error:<br />$_";
        error "$_";
        template 'libraries_edit', { library => $library };
    };

};

get '/libraries/delete/:id?' => require_role superadmin => sub { 
    
    # Confirm delete
    my $id = param 'id';
    my $library = rset('Library')->find( $id );
    template 'libraries_delete', { library => $library };
    
};

get '/libraries/delete_ok/:id?' => require_role superadmin => sub { 
    
    # Do the actual delete
    my $id = param 'id';
    my $library = rset('Library')->find( $id );
    # TODO Check that this library is ready to be deleted!
    try {
        $library->delete;
        flash info => 'A library was deleted!';
        info "Deleted library with ID = $id";
        redirect '/superadmin';
    } catch {
        flash error => "Oops, we got an error:<br />$_";
        error "$_";
        redirect '/superadmin';
    };
    
};

### Local users

get '/users/add' => require_role superadmin => sub { 
    my @libraries = rset('Library')->all;
    template 'users_add', { libraries => \@libraries };
};

post '/users/add' => require_role superadmin => sub {

    my $name       = param 'name';
    my $username   = param 'username';
    my $password1  = param 'password1';
    my $password2  = param 'password2';
    my $library_id = param 'library';  
    
    # Check the provided data
    _check_password_length( $password1 )             or return template 'users_add';
    _check_password_match(  $password1, $password2 ) or return template 'users_add';
    
    # Data looks good, try to save it
    try {
        my $new_user = rset('User')->create({
            username => $username, 
            password => _encrypt_password($password1), 
            name     => $name,
        });
        debug "*** Created new user with ID = " . $new_user->id;
        # debug Dumper $new_user;
        if ( $library_id ) {
            rset('UserLibrary')->create({
                user_id    => $new_user->id, 
                library_id => $library_id, 
            });
        }
        flash info => 'A new user was added!';
        redirect '/superadmin';
    } catch {
        flash error => "Oops, we got an error:<br />$_";
        error "$_";
        template 'users_add', { name => $name };
    };

};

get '/users/edit/:id' => require_role superadmin => sub {

    my $id = param 'id';
    my $user = rset('User')->find( $id );
    template 'users_edit', { user => $user };

};

post '/users/edit' => require_role superadmin => sub {

    my $id   = param 'id';
    my $username = param 'username';
    my $name     = param 'name';
    my $user = rset('User')->find( $id );
    try {
        $user->set_column('username', $username);
        $user->set_column('name', $name);
        $user->update;
        flash info => 'A user was updated!';
        redirect '/superadmin';
    } catch {
        flash error => "Oops, we got an error:<br />$_";
        error "$_";
        template 'users_edit', { user => $user };
    };

};

get '/users/password/:id' => require_role superadmin => sub {
    template 'users_password';
};

post '/users/password' => require_role superadmin => sub {

    my $id        = param 'id';
    my $password1 = param 'password1';
    my $password2 = param 'password2'; 
    
    # Check the provided data
    _check_password_length( $password1 )             or return template 'users_password', { id => $id };
    _check_password_match(  $password1, $password2 ) or return template 'users_password', { id => $id };
    
    # Data looks good, try to save it
    my $user = rset('User')->find( $id );
    try {
        $user->set_column( 'password', _encrypt_password($password1) );
        $user->update;
        flash info => "The password was updated for user with ID = $id!";
        redirect '/superadmin';
    } catch {
        flash error => "Oops, error when trying to update password:<br />$_";
        error "$_";
        template 'users_password', { id => $id };
    };

};

get '/users/roles/:id' => require_role superadmin => sub { 
    
    my $id = param 'id';
    my $user = rset('User')->find( $id );
    my @roles = rset('Role')->all;
    template 'users_roles', { user => $user, roles => \@roles };
    
};

get '/users/roles/add/:user_id/:role_id' => require_role superadmin => sub { 
    
    my $user_id = param 'user_id';
    my $role_id = param 'role_id';
    try {
        rset('UserRole')->create({
            user_id => $user_id, 
            role_id => $role_id, 
        });
        flash info => 'A new role was added!';
        redirect '/users/roles/' . $user_id;
    } catch {
        flash error => "Oops, we got an error:<br />$_";
        error "$_";
        redirect '/users/roles/' . $user_id;
    };    
};

get '/users/roles/delete/:user_id/:role_id' => require_role superadmin => sub { 
    
    my $user_id = param 'user_id';
    my $role_id = param 'role_id';
    my $role = rset('UserRole')->find({ user_id => $user_id, role_id => $role_id });
    try {
        $role->delete;
        flash info => 'A role was deleted!';
        redirect '/users/roles/' . $user_id;
    } catch {
        flash error => "Oops, we got an error:<br />$_";
        error "$_";
        redirect '/users/roles/' . $user_id;
    };
    
};

get '/users/libraries/:id' => require_role superadmin => sub { 
    
    my $id = param 'id';
    my $user = rset('User')->find( $id );
    my @libraries = rset('Library')->all;
    template 'users_libraries', { user => $user, libraries => \@libraries };
    
};

# Add a connection between user and library
get '/users/libraries/add/:user_id/:library_id' => require_role superadmin => sub { 
    
    my $user_id    = param 'user_id';
    my $library_id = param 'library_id';
    try {
        rset('UserLibrary')->create({
            user_id    => $user_id, 
            library_id => $library_id, 
        });
        flash info => 'A new library was connected!';
        redirect '/users/libraries/' . $user_id;
    } catch {
        flash error => "Oops, we got an error:<br />$_";
        error "$_";
        redirect '/users/libraries/' . $user_id;
    };    
};

get '/users/libraries/delete/:user_id/:library_id' => require_role superadmin => sub { 
    
    my $user_id    = param 'user_id';
    my $library_id = param 'library_id';
    my $connection = rset('UserLibrary')->find({ user_id => $user_id, library_id => $library_id });
    # TODO Check that this user is ready to be deleted!
    try {
        $connection->delete;
        flash info => 'A connection was deleted!';
        redirect '/users/libraries/' . $user_id;
    } catch {
        flash error => "Oops, we got an error:<br />$_";
        error "$_";
        redirect '/users/libraries/' . $user_id;
    };
    
};

get '/users/delete/:id?' => require_role superadmin => sub { 
    
    # Confirm delete
    my $id = param 'id';
    my $user = rset('User')->find( $id );
    template 'users_delete', { user => $user };
    
};

get '/users/delete_ok/:id?' => require_role superadmin => sub { 
    
    # Do the actual delete
    my $id = param 'id';
    my $user = rset('User')->find( $id );
    # TODO Check that this user is ready to be deleted!
    try {
        $user->delete;
        flash info => 'A user was deleted!';
        info "Deleted user with ID = $id";
        redirect '/superadmin';
    } catch {
        flash error => "Oops, we got an error:<br />$_";
        error "$_";
        redirect '/superadmin';
    };
    
};

### Utility functions
# TODO Move these to a separate .pm

sub _check_password_length {
    my ( $password1 ) = @_;
    if ( length $password1 < config->{min_pass} ) {
        error "*** Password is too short: " . length $password1;
        flash error => 'Passwords is too short! (The minimum is ' . config->{min_pass} . '.)';
        return 0;
    } else {
        return 1;
    }
}

sub _check_password_match {
    my ( $password1, $password2 ) = @_;
    if ( $password1 ne $password2 ) {
        error "*** Passwords do not match";
        flash error => "Passwords do not match!";
        return 0;
    } else {
        return 1;
    }
}

sub _encrypt_password {
    my $password = shift;
    my $csh = Crypt::SaltedHash->new();
    $csh->add( $password );
    return $csh->generate;
}

true;