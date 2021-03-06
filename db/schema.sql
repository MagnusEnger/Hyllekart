-- Database schema for Hyllekart

DROP TABLE IF EXISTS user_roles;
DROP TABLE IF EXISTS user_libraries;
DROP TABLE IF EXISTS maps;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
    id       INTEGER     AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(32) NOT NULL       UNIQUE KEY,
    password VARCHAR(64) NOT NULL, 
    name     VARCHAR(255) 
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS roles;
CREATE TABLE roles (
    id    INTEGER     AUTO_INCREMENT PRIMARY KEY,
    role  VARCHAR(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS libraries;
CREATE TABLE libraries (
    id   INTEGER AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) UNIQUE KEY NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE user_roles (
    user_id    INTEGER NOT NULL,
    role_id    INTEGER NOT NULL,
    PRIMARY KEY user_role (user_id, role_id), 
    CONSTRAINT user_roles_fk_1 FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT user_roles_fk_2 FOREIGN KEY (role_id) REFERENCES roles (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE user_libraries (
    user_id    INTEGER NOT NULL,
    library_id INTEGER NOT NULL,
    PRIMARY KEY user_library (user_id, library_id), 
    CONSTRAINT user_libraries_fk_1 FOREIGN KEY (user_id)    REFERENCES users     (id) ON DELETE CASCADE,
    CONSTRAINT user_libraries_fk_2 FOREIGN KEY (library_id) REFERENCES libraries (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE maps (
    map_id INTEGER AUTO_INCREMENT PRIMARY KEY,
    name   VARCHAR(255) UNIQUE KEY NOT NULL, 
    library_id INTEGER NOT NULL,
    CONSTRAINT maps_fk_1 FOREIGN KEY (library_id) REFERENCES libraries (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- Sample data
-- TODO Split this out into a separate file

-- Roles
INSERT INTO roles SET id = 1, role = 'admin';
INSERT INTO roles SET id = 2, role = 'superadmin';

-- Users
INSERT INTO users SET id = 1, username = 'henrik', password = '{SSHA}naJx7DlkVcnRkTUm2sOzg5IsaYPfm76H', name = 'Henrik Ibsen';  -- password = pass
INSERT INTO users SET id = 2, username = 'sigrid', password = '{SSHA}qf4CXx0V8668B8QzYGcGpHdyBWEhCv55', name = 'Sigrid Undset'; -- password = pass

-- Libraries
INSERT INTO libraries SET id = 1, name = 'Storevik';
INSERT INTO libraries SET id = 2, name = 'Lillevik';

-- Users and roles
INSERT INTO user_roles SET user_id = 1, role_id = 1; -- Henrik is admin at Storevik
INSERT INTO user_roles SET user_id = 2, role_id = 2; -- Sigrid is superadmin, not connected to a library

-- Users and libraries
INSERT INTO user_libraries SET user_id = 1, library_id = 1;

-- Maps
INSERT INTO maps SET map_id = 1, library_id = 1, name = 'Ground floor';
INSERT INTO maps SET map_id = 2, library_id = 1, name = 'First floor';
