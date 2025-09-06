-- Create notifications table for UMaT E-Health app
-- Run this in your Supabase SQL editor

-- Create notifications table
CREATE TABLE IF NOT EXISTS public.notifications (
    id TEXT PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('appointment', 'message', 'call', 'reminder', 'tip', 'emergency')),
    is_read BOOLEAN DEFAULT FALSE,
    data JSONB,
    action_route TEXT,
    action_params JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON public.notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON public.notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_type ON public.notifications(type);

-- Enable Row Level Security
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Users can view their own notifications" ON public.notifications
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own notifications" ON public.notifications
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "System can insert notifications" ON public.notifications
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can delete their own notifications" ON public.notifications
    FOR DELETE USING (auth.uid() = user_id);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_notifications_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_notifications_updated_at_trigger
    BEFORE UPDATE ON public.notifications
    FOR EACH ROW
    EXECUTE FUNCTION update_notifications_updated_at();

-- Insert some sample notifications for testing
INSERT INTO public.notifications (id, user_id, title, body, type, is_read, action_route) VALUES
    ('notif_1', (SELECT id FROM auth.users WHERE email = 'ce-chris1234@st.umat.edu.gh' LIMIT 1), 'Appointment Reminder', 'You have an appointment with Dr. Sarah Johnson in 30 minutes', 'appointment', false, '/appointments'),
    ('notif_2', (SELECT id FROM auth.users WHERE email = 'ce-chris1234@st.umat.edu.gh' LIMIT 1), 'New Message', 'Dr. Emmanuel Mensah sent you a message', 'message', false, '/chat'),
    ('notif_3', (SELECT id FROM auth.users WHERE email = 'ce-chris1234@st.umat.edu.gh' LIMIT 1), 'Health Tip', 'Remember to stay hydrated! Drink 8 glasses of water daily.', 'tip', false, NULL),
    ('notif_4', (SELECT id FROM auth.users WHERE email = 'ce-chris1234@st.umat.edu.gh' LIMIT 1), 'Lab Results Ready', 'Your blood test results are now available', 'reminder', false, '/medical-records'),
    ('notif_5', (SELECT id FROM auth.users WHERE email = 'ce-chris1234@st.umat.edu.gh' LIMIT 1), 'Prescription Ready', 'Your prescription is ready for pickup', 'reminder', false, '/prescriptions')
ON CONFLICT (id) DO NOTHING;

-- Insert notifications for staff users
INSERT INTO public.notifications (id, user_id, title, body, type, is_read, action_route) VALUES
    ('notif_staff_1', (SELECT id FROM auth.users WHERE email = 'dr.sarah@umat.edu.gh' LIMIT 1), 'New Patient Message', 'Chris Enimil sent you a message', 'message', false, '/chat'),
    ('notif_staff_2', (SELECT id FROM auth.users WHERE email = 'dr.sarah@umat.edu.gh' LIMIT 1), 'Appointment Scheduled', 'New appointment with Paul Botchwey at 2:00 PM', 'appointment', false, '/appointments'),
    ('notif_staff_3', (SELECT id FROM auth.users WHERE email = 'dr.sarah@umat.edu.gh' LIMIT 1), 'System Update', 'New health tips available for patients', 'reminder', false, NULL)
ON CONFLICT (id) DO NOTHING;

-- Verify the table was created successfully
SELECT 
    'NOTIFICATIONS_TABLE_CREATED' as status,
    COUNT(*) as total_notifications,
    COUNT(CASE WHEN is_read = false THEN 1 END) as unread_notifications
FROM public.notifications;
