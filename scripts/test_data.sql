ALTER SEQUENCE user_id_seq RESTART WITH 1;
ALTER SEQUENCE post_id_seq RESTART WITH 1;
ALTER SEQUENCE note_id_seq RESTART WITH 1;
ALTER SEQUENCE "Team_id_seq" RESTART WITH 1;

INSERT INTO javarush_db.public."user" (name, surname, email, date_of_birth, password)
VALUES ('Nikolay', 'Melnikov', 'hrom_90@hotmail.com', '1990-07-30', 'password'),
       ('Irina', 'Melnikova', 'ddd@gmail.com', '1989-04-05', 'psss'),
       ('Nikita', 'Ivanov', 'aaa@gmail.com', '1954-09-26', 'titomir'),
       ('Sergey', 'Petrov', 'petrov@gmail.com', '1989-05-21', 'endura'),
       ('Valentin', 'Krymov', 'vk@gmail.com', '1988-03-18', 'qqqeeer'),
       ('Igor', 'Kirillov', 'kirillov@yandex.ru', '1974-06-31', 'argentum'),
       ('Maxim', 'Letishev', 'maxpower@gmail.com', '1996-08-15', 'aurum'),
       ('Viktoriya', 'Kopytina', 'vika_smile@mail.ru', '1997-12-10', 'plumbum'),
       ('Harry', 'Potter', 'potter@yahoo.com', '1980-07-31', 'flash'),
       ('Tomas', 'Reddle', 'noonenoticeevilinme@hotmail.com', '1926-12-31', 'flesh');

INSERT INTO javarush_db.public.team (team_name)
values ('Alfa-ras'),
       ('Antares'),
       ('Betelgeuse');

INSERT INTO team_user(team_id, user_id)
values ((SELECT id FROM team WHERE team_name = 'Alfa-ras'),
        (SELECT u.id FROM javarush_db.public."user" u WHERE u.email = 'hrom_90@hotmail.com'));

INSERT INTO team_user(team_id, user_id)
values ((SELECT id FROM team WHERE team_name = 'Antares'),
        (SELECT u.id FROM javarush_db.public."user" u WHERE u.email = 'ddd@gmail.com')),
       ((SELECT id FROM team WHERE team_name = 'Antares'),
        (SELECT u.id FROM javarush_db.public."user" u WHERE u.email = 'maxpower@gmail.com')),
       ((SELECT id FROM team WHERE team_name = 'Antares'),
        (SELECT u.id FROM javarush_db.public."user" u WHERE u.email = 'kirillov@yandex.ru'));
INSERT INTO team_user(team_id, user_id)
values ((SELECT id FROM team WHERE team_name = 'Betelgeuse'),
        (SELECT u.id FROM javarush_db.public."user" u WHERE u.email = 'hrom_90@hotmail.com'));

INSERT INTO notepad(title, cover)
values ('Notes for me', 'black'),
       ('Notes for you', 'red'),
       ('Notes for us', 'white'),
       ('Notes for them', 'green'),
       ('Notes for it', 'blue'),
       ('Notes for work', 'black'),
       ('Notes for memory', 'red'),
       ('Notes for anyone', 'green'),
       ('Notes for aftermath', 'white'),
       ('Notes for day', 'black');

INSERT INTO user_notepad (user_id, notepad_id)
VALUES ((SELECT u.id FROM "user" u WHERE u.email = 'noonenoticeevilinme@hotmail.com'),
        (SELECT np.id FROM notepad np WHERE np.id = 1));
INSERT INTO user_notepad (user_id, notepad_id)
VALUES ((SELECT u.id FROM "user" u WHERE u.email = 'ddd@gmail.com'),
        (SELECT np.id FROM notepad np WHERE np.id = 1));
INSERT INTO user_notepad (user_id, notepad_id)
VALUES ((SELECT u.id FROM "user" u WHERE u.email = 'noonenoticeevilinme@hotmail.com'),
        (SELECT np.id FROM notepad np WHERE np.id = 2));
INSERT INTO user_notepad (user_id, notepad_id)
VALUES ((SELECT u.id FROM "user" u WHERE u.email = 'kirillov@yandex.ru'),
        (SELECT np.id FROM notepad np WHERE np.id = 3));
INSERT INTO user_notepad (user_id, notepad_id)
VALUES ((SELECT u.id FROM "user" u WHERE u.email = 'aaa@gmail.com'),
        (SELECT np.id FROM notepad np WHERE np.id = 4));
INSERT INTO user_notepad (user_id, notepad_id)
VALUES ((SELECT u.id FROM "user" u WHERE u.email = 'petrov@gmail.com'),
        (SELECT np.id FROM notepad np WHERE np.id = 5));
INSERT INTO user_notepad (user_id, notepad_id)
VALUES ((SELECT u.id FROM "user" u WHERE u.email = 'vk@gmail.com'),
        (SELECT np.id FROM notepad np WHERE np.id = 6));
INSERT INTO user_notepad (user_id, notepad_id)
VALUES ((SELECT u.id FROM "user" u WHERE u.email = 'vika_smile@mail.ru'),
        (SELECT np.id FROM notepad np WHERE np.id = 7));
INSERT INTO user_notepad (user_id, notepad_id)
VALUES ((SELECT u.id FROM "user" u WHERE u.email = 'maxpower@gmail.com'),
        (SELECT np.id FROM notepad np WHERE np.id = 8));
INSERT INTO user_notepad (user_id, notepad_id)
VALUES ((SELECT u.id FROM "user" u WHERE u.email = 'potter@yahoo.com'),
        (SELECT np.id FROM notepad np WHERE np.id = 9));
INSERT INTO user_notepad (user_id, notepad_id)
VALUES ((SELECT u.id FROM "user" u WHERE u.email = 'hrom_90@hotmail.com'),
        (SELECT np.id FROM notepad np WHERE np.id = 9));

