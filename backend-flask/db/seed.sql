-- this file was manually created
INSERT INTO public.users (display_name, email, handle, cognito_user_id)
VALUES
  ('Donny Darko', 'donatellidarko@gmail.com', 'donnydarko', 'MOCK'),
  ('Andrew Bayko', 'bayko@exampro.co', 'bayko', 'MOCK'),
  ('Londo Mollari','lmollari@centari.com' ,'londo' ,'MOCK'),
  ('Mat Bet','martinabetianbe@gmail.com' , 'matbet' ,'MOCK');

INSERT INTO public.activities (user_uuid, message, expires_at)
VALUES
  (
    (SELECT uuid from public.users WHERE users.handle = 'donnydarko' LIMIT 1),
    'This was imported as seed data!',
    current_timestamp + interval '10 day'
  ),
  (
    (SELECT uuid from public.users WHERE users.handle = 'matbet' LIMIT 1),
    'I am the other!',
    current_timestamp + interval '10 day'
  );