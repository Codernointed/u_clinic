-- ============================================================================
-- CHECK CHAT TABLE STRUCTURE
-- Run this to check the actual structure of the chats table
-- ============================================================================

-- 1. Check chat table structure
SELECT '=== CHAT TABLE STRUCTURE ===' as section;
SELECT 
    column_name, 
    data_type, 
    is_nullable
FROM 
    information_schema.columns 
WHERE 
    table_name = 'chats'
ORDER BY 
    ordinal_position;

-- 2. Check chat_messages table structure
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

-- 3. Count chats and messages
SELECT '=== CHAT AND MESSAGE COUNTS ===' as section;
SELECT 'Chats' as item, COUNT(*) as count FROM chats
UNION ALL
SELECT 'Messages' as item, COUNT(*) as count FROM chat_messages;

-- 4. Check if we have any messages in the database
SELECT '=== SAMPLE MESSAGES ===' as section;
SELECT 
    id, 
    chat_id, 
    sender_id, 
    content, 
    created_at
FROM 
    chat_messages
ORDER BY 
    created_at DESC
LIMIT 5;

-- 5. Check if we have any chats in the database
SELECT '=== SAMPLE CHATS ===' as section;
SELECT 
    id, 
    patient_id, 
    patient_name, 
    subject, 
    status, 
    created_at
FROM 
    chats
ORDER BY 
    created_at DESC
LIMIT 5;

-- 6. Join chats with messages to see if they're linked correctly
SELECT '=== CHATS WITH MESSAGE COUNTS ===' as section;
SELECT 
    c.id as chat_id,
    c.patient_name,
    c.subject,
    c.status,
    COUNT(cm.id) as message_count
FROM 
    chats c
LEFT JOIN 
    chat_messages cm ON c.id = cm.chat_id
GROUP BY 
    c.id, c.patient_name, c.subject, c.status
ORDER BY 
    message_count DESC;

SELECT '✅ Check complete!' as status;
