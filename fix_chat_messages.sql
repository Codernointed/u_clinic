-- ============================================================================
-- FIX CHAT MESSAGES DISPLAY ISSUE
-- This script will diagnose and fix issues with chat messages not displaying
-- ============================================================================

-- 1. Check chat_messages table structure
SELECT '=== CHAT MESSAGES TABLE STRUCTURE ===' as section;
SELECT 
    column_name, 
    data_type, 
    is_nullable
FROM 
    information_schema.columns 
WHERE 
    table_name = 'chat_messages'
ORDER BY 
    ordinal_position;

-- 2. Sample chat messages to verify data
SELECT '=== SAMPLE CHAT MESSAGES ===' as section;
SELECT * FROM chat_messages LIMIT 5;

-- 3. Check if the messages have valid sender_ids
SELECT '=== MESSAGES WITH NULL SENDER_IDS ===' as section;
SELECT COUNT(*) as null_sender_count FROM chat_messages WHERE sender_id IS NULL;

-- 4. Check if the messages have valid chat_ids
SELECT '=== MESSAGES WITH INVALID CHAT_IDS ===' as section;
SELECT COUNT(*) as invalid_chat_count 
FROM chat_messages cm
LEFT JOIN chats c ON cm.chat_id = c.id
WHERE c.id IS NULL;

-- 5. Fix any NULL sender_ids (if needed)
UPDATE chat_messages
SET sender_id = '051236eb-aa62-4432-a577-8f4efdae9417'  -- Default to a known user ID
WHERE sender_id IS NULL;

-- 6. Create a view to help debug chat messages
CREATE OR REPLACE VIEW chat_messages_debug AS
SELECT 
    cm.id as message_id,
    cm.chat_id,
    cm.sender_id,
    u.first_name || ' ' || u.last_name as sender_name,
    cm.content,
    cm.message_type,
    cm.is_read,
    cm.created_at,
    c.subject as chat_subject,
    c.patient_name,
    c.status as chat_status
FROM 
    chat_messages cm
LEFT JOIN 
    chats c ON cm.chat_id = c.id
LEFT JOIN
    users u ON cm.sender_id = u.id
ORDER BY 
    cm.created_at DESC;

-- 7. View the debug data
SELECT '=== CHAT MESSAGES DEBUG VIEW ===' as section;
SELECT * FROM chat_messages_debug LIMIT 10;

-- 8. Check for any messages with missing content
SELECT '=== MESSAGES WITH EMPTY CONTENT ===' as section;
SELECT COUNT(*) as empty_content_count FROM chat_messages WHERE content IS NULL OR content = '';

-- 9. Check for any messages with invalid created_at dates
SELECT '=== MESSAGES WITH INVALID DATES ===' as section;
SELECT COUNT(*) as invalid_date_count FROM chat_messages WHERE created_at IS NULL;

-- 10. Fix any messages with NULL created_at dates (if needed)
UPDATE chat_messages
SET created_at = NOW()
WHERE created_at IS NULL;

-- 11. Add indexes to improve query performance
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_chat_messages_chat_id') THEN
        CREATE INDEX idx_chat_messages_chat_id ON chat_messages(chat_id);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_chat_messages_sender_id') THEN
        CREATE INDEX idx_chat_messages_sender_id ON chat_messages(sender_id);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_chat_messages_created_at') THEN
        CREATE INDEX idx_chat_messages_created_at ON chat_messages(created_at);
    END IF;
END $$;

SELECT '✅ Chat messages fixes applied!' as status;
