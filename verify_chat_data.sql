-- ============================================================================
-- VERIFY CHAT DATA
-- Run this to verify all chat data is properly structured
-- ============================================================================

-- 1. Check chat_messages structure
SELECT '=== CHAT MESSAGES STRUCTURE ===' as section;
SELECT 
    cm.id,
    cm.chat_id,
    cm.sender_id,
    cm.message_type,
    cm.content,
    cm.created_at,
    c.patient_name as chat_patient,
    c.subject as chat_subject
FROM chat_messages cm
JOIN chats c ON cm.chat_id = c.id
ORDER BY cm.created_at DESC
LIMIT 10;

-- 2. Check if all messages have valid chat IDs
SELECT '=== MESSAGES WITH INVALID CHAT IDS ===' as section;
SELECT COUNT(*) as invalid_messages
FROM chat_messages cm
LEFT JOIN chats c ON cm.chat_id = c.id
WHERE c.id IS NULL;

-- 3. Check chats for specific user
SELECT '=== CHATS FOR USER Paul (051236eb-aa62-4432-a577-8f4efdae9417) ===' as section;
SELECT 
    id,
    patient_id,
    patient_name,
    subject,
    status,
    created_at
FROM chats
WHERE patient_id = '051236eb-aa62-4432-a577-8f4efdae9417'
   OR staff_id = '051236eb-aa62-4432-a577-8f4efdae9417'
ORDER BY created_at DESC;

-- 4. Count messages per chat
SELECT '=== MESSAGE COUNT PER CHAT ===' as section;
SELECT 
    c.id as chat_id,
    c.subject,
    c.patient_name,
    COUNT(cm.id) as message_count
FROM chats c
LEFT JOIN chat_messages cm ON c.id = cm.chat_id
GROUP BY c.id, c.subject, c.patient_name
ORDER BY c.created_at DESC;

-- 5. Recent messages
SELECT '=== RECENT MESSAGES ===' as section;
SELECT 
    cm.id,
    cm.chat_id,
    cm.sender_id,
    cm.content,
    cm.created_at,
    CASE 
        WHEN cm.sender_id = c.patient_id THEN 'Patient'
        ELSE 'Staff'
    END as sender_type
FROM chat_messages cm
JOIN chats c ON cm.chat_id = c.id
ORDER BY cm.created_at DESC
LIMIT 10;

SELECT '✅ Verification complete!' as status;
