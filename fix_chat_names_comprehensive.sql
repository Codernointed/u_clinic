-- Comprehensive fix for chat names and database schema
-- Run this in your Supabase SQL editor

-- 1. Add missing columns if they don't exist
ALTER TABLE public.chats 
ADD COLUMN IF NOT EXISTS staff_name TEXT;

-- 2. Update existing chats with proper patient names
UPDATE public.chats 
SET patient_name = CONCAT(u.first_name, ' ', u.last_name)
FROM public.users u 
WHERE chats.patient_id = u.id 
AND (chats.patient_name IS NULL OR chats.patient_name = '' OR chats.patient_name LIKE '%User %');

-- 3. Update existing chats with proper staff names
UPDATE public.chats 
SET staff_name = CONCAT(u.first_name, ' ', u.last_name)
FROM public.users u 
WHERE chats.staff_id = u.id 
AND (chats.staff_name IS NULL OR chats.staff_name = '' OR chats.staff_name LIKE '%User %');

-- 4. Fix any remaining "User" prefixed names
UPDATE public.chats 
SET patient_name = CONCAT(u.first_name, ' ', u.last_name)
FROM public.users u 
WHERE chats.patient_id = u.id 
AND chats.patient_name LIKE 'User %';

UPDATE public.chats 
SET staff_name = CONCAT(u.first_name, ' ', u.last_name)
FROM public.users u 
WHERE chats.staff_id = u.id 
AND chats.staff_name LIKE 'User %';

-- 5. Check the results
SELECT 
    id,
    patient_id,
    patient_name,
    staff_id,
    staff_name,
    chat_type,
    status,
    created_at
FROM public.chats 
ORDER BY created_at DESC 
LIMIT 10;

-- 6. Check users table to ensure names are populated
SELECT 
    id,
    first_name,
    last_name,
    email,
    role
FROM public.users 
WHERE role IN ('patient', 'staff', 'admin')
ORDER BY created_at DESC 
LIMIT 10;
