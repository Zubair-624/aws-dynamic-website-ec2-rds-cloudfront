-- Create the database (if it does not EXISTS)
CREATE DATABASE IF NOT EXISTS web_application;

-- Use this database
USE web_application;

-----------------------------------------------------------------------------------
-- Table 1: visitor counter
-- Stores a single row that tracks total visit count
CREATE TABLE IF NOT EXISTS visitors (
    id INT AUTO_INCREMENT PRIMARY KEY,

    count INT DEFAULT 0,

    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP 

);

-- Insert the first row (visit counter starts at 0)
INSERT INTO visitors (count) VALUES (0);
-----------------------------------------------------------------------------------

-----------------------------------------------------------------------------------
-- Table 2: messages
-- Each row is one message left by a visitor
CREATE TABLE IF NOT EXISTS messages (
    id INT AUTO_INCREMENT PRIMARY KEY,

    name VARCHAR(100) NOT NULL,

    message TEXT NOT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
);
-----------------------------------------------------------------------------------
