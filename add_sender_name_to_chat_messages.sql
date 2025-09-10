-- Add sender_name to chat_messages and backfill
-- Run in Supabase SQL editor

-- Add column if missing
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'chat_messages'
      AND column_name = 'sender_name'
  ) THEN
    ALTER TABLE public.chat_messages
      ADD COLUMN sender_name TEXT;
  END IF;
END $$;

-- Backfill names from users table
UPDATE public.chat_messages m
SET sender_name = CONCAT(u.first_name, ' ', u.last_name)
FROM public.users u
WHERE m.sender_id = u.id
  AND (m.sender_name IS NULL OR m.sender_name = '');

-- Ensure not null going forward by defaulting to 'Unknown User'
UPDATE public.chat_messages
SET sender_name = 'Unknown User'
WHERE sender_name IS NULL OR sender_name = '';

-- Optional: add a trigger to keep it in sync on insert if desired
CREATE OR REPLACE FUNCTION public.set_chat_message_sender_name()
RETURNS trigger AS $$
BEGIN
  IF NEW.sender_name IS NULL OR NEW.sender_name = '' THEN
    SELECT CONCAT(u.first_name, ' ', u.last_name)
      INTO NEW.sender_name
    FROM public.users u
    WHERE u.id = NEW.sender_id;
    IF NEW.sender_name IS NULL OR NEW.sender_name = '' THEN
      NEW.sender_name := 'Unknown User';
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_set_chat_message_sender_name ON public.chat_messages;
CREATE TRIGGER trg_set_chat_message_sender_name
BEFORE INSERT ON public.chat_messages
FOR EACH ROW EXECUTE FUNCTION public.set_chat_message_sender_name();

-- Verify
SELECT 'CHAT_MESSAGES_SENDER_NAME_FIXED' AS status,
       COUNT(*) AS total,
       COUNT(CASE WHEN sender_name IS NULL OR sender_name = '' THEN 1 END) AS missing_names
FROM public.chat_messages;




