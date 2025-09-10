-- Fix notifications table schema immediately
-- This will fix the appointment booking error

-- Drop existing notifications table if it exists
DROP TABLE IF EXISTS public.notifications CASCADE;

-- Create notifications table with correct schema
CREATE TABLE public.notifications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    body TEXT NOT NULL,  -- Changed from 'message' to 'body'
    type TEXT DEFAULT 'info',
    is_read BOOLEAN DEFAULT FALSE,
    data JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Users can view their own notifications" ON public.notifications
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own notifications" ON public.notifications
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "System can insert notifications" ON public.notifications
    FOR INSERT WITH CHECK (true);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_notifications_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_notifications_updated_at
    BEFORE UPDATE ON public.notifications
    FOR EACH ROW
    EXECUTE FUNCTION update_notifications_updated_at();

-- Insert sample notifications for testing
INSERT INTO public.notifications (user_id, title, body, type) VALUES
    ('6d848866-0ce5-46e2-8afe-fff372dfdd63', 'Welcome!', 'Welcome to UMaT E-Health', 'info'),
    ('6d848866-0ce5-46e2-8afe-fff372dfdd63', 'Appointment Booked', 'Your appointment has been successfully booked', 'success'),
    ('6d848866-0ce5-46e2-8afe-fff372dfdd63', 'Video Call Available', 'You can now join your video consultation', 'info');

-- Grant permissions
GRANT ALL ON public.notifications TO authenticated;
GRANT ALL ON public.notifications TO service_role;

-- Show success message
SELECT 'Notifications table fixed successfully!' as status;

