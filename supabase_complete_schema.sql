-- ============================================================================
-- U_CLINIC COMPLETE DATABASE SCHEMA - PREMIUM VERSION
-- University Interactive E-Health Application
-- Created: January 2025
-- ============================================================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- 1. ENHANCED USERS TABLE (extends default auth.users)
-- ============================================================================

-- Create public users table with additional healthcare fields
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email VARCHAR(255) UNIQUE NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('patient', 'staff', 'admin')),
    
    -- Personal Information
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20),
    date_of_birth DATE,
    gender VARCHAR(10) CHECK (gender IN ('male', 'female', 'other')),
    profile_image_url TEXT,
    
    -- University Information
    student_id VARCHAR(50),
    staff_id VARCHAR(50),
    department VARCHAR(100),
    year_of_study INTEGER,
    
    -- Medical Information (for patients)
    blood_group VARCHAR(5),
    allergies TEXT[],
    medications TEXT[],
    presenting_symptoms TEXT[],
    medical_conditions TEXT[],
    
    -- Emergency Contact
    emergency_contact_name VARCHAR(200),
    emergency_contact_phone VARCHAR(20),
    emergency_contact_relationship VARCHAR(50),
    
    -- Security & Verification
    is_email_verified BOOLEAN DEFAULT FALSE,
    is_2fa_enabled BOOLEAN DEFAULT FALSE,
    last_login_at TIMESTAMP WITH TIME ZONE,
    
    -- Audit Fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT valid_student_email CHECK (
        role != 'patient' OR email LIKE '%@st.umat.edu.gh'
    ),
    CONSTRAINT student_id_required CHECK (
        (role = 'patient' AND student_id IS NOT NULL) OR 
        (role != 'patient')
    ),
    CONSTRAINT staff_id_required CHECK (
        (role IN ('staff', 'admin') AND staff_id IS NOT NULL) OR 
        (role = 'patient')
    )
);

-- ============================================================================
-- 2. DEPARTMENTS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.departments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    head_of_department VARCHAR(200),
    location VARCHAR(200),
    phone_number VARCHAR(20),
    email VARCHAR(255),
    operating_hours JSONB, -- {"monday": "08:00-17:00", "tuesday": "08:00-17:00", ...}
    services TEXT[],
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- 3. DOCTORS/STAFF TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.doctors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    staff_id VARCHAR(50) UNIQUE NOT NULL,
    
    -- Professional Information
    title VARCHAR(20) NOT NULL, -- Dr., Prof., Mr., Ms., etc.
    specialization VARCHAR(100),
    qualification VARCHAR(500),
    license_number VARCHAR(100),
    years_of_experience INTEGER,
    
    -- Department & Schedule
    department_id UUID REFERENCES public.departments(id),
    consultation_fee DECIMAL(10,2),
    consultation_duration INTEGER DEFAULT 30, -- minutes
    
    -- Availability (JSON format for flexible scheduling)
    weekly_schedule JSONB, -- {"monday": [{"start": "09:00", "end": "12:00"}, {"start": "14:00", "end": "17:00"}], ...}
    break_times JSONB, -- [{"start": "12:00", "end": "13:00"}]
    
    -- Contact & Bio
    bio TEXT,
    languages TEXT[],
    
    -- Status
    is_available BOOLEAN DEFAULT TRUE,
    is_accepting_patients BOOLEAN DEFAULT TRUE,
    
    -- Audit Fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- 4. ENHANCED APPOINTMENTS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.appointments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Participants
    patient_id UUID NOT NULL REFERENCES public.users(id),
    doctor_id UUID NOT NULL REFERENCES public.doctors(id),
    
    -- Schedule Information
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    estimated_duration INTEGER DEFAULT 30, -- minutes
    
    -- Appointment Details
    consultation_type VARCHAR(20) NOT NULL CHECK (consultation_type IN ('in_person', 'video', 'voice', 'text')),
    department_id UUID REFERENCES public.departments(id),
    reason_for_visit TEXT NOT NULL,
    symptoms TEXT,
    notes TEXT,
    priority VARCHAR(20) DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'emergency')),
    
    -- Status Management
    status VARCHAR(20) NOT NULL DEFAULT 'scheduled' CHECK (
        status IN ('scheduled', 'confirmed', 'in_progress', 'completed', 'cancelled', 'no_show', 'rescheduled')
    ),
    
    -- Cancellation/Rescheduling
    cancelled_at TIMESTAMP WITH TIME ZONE,
    cancellation_reason TEXT,
    cancelled_by UUID REFERENCES public.users(id),
    rescheduled_from UUID REFERENCES public.appointments(id),
    
    -- Follow-up
    follow_up_required BOOLEAN DEFAULT FALSE,
    follow_up_date DATE,
    follow_up_notes TEXT,
    
    -- Billing (for future use)
    consultation_fee DECIMAL(10,2),
    payment_status VARCHAR(20) DEFAULT 'pending' CHECK (
        payment_status IN ('pending', 'paid', 'waived', 'refunded')
    ),
    
    -- Audit Fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT future_appointment CHECK (
        appointment_date >= CURRENT_DATE OR 
        (appointment_date = CURRENT_DATE AND appointment_time >= CURRENT_TIME)
    ),
    CONSTRAINT valid_duration CHECK (estimated_duration > 0 AND estimated_duration <= 240)
);

-- ============================================================================
-- 5. MEDICAL RECORDS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.medical_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Patient & Provider
    patient_id UUID NOT NULL REFERENCES public.users(id),
    doctor_id UUID REFERENCES public.doctors(id),
    appointment_id UUID REFERENCES public.appointments(id),
    
    -- Record Classification
    record_type VARCHAR(50) NOT NULL CHECK (
        record_type IN ('consultation', 'prescription', 'lab_result', 'imaging', 
                       'vaccination', 'surgery', 'diagnosis', 'treatment_plan', 'referral')
    ),
    
    -- Record Content
    title VARCHAR(200) NOT NULL,
    description TEXT,
    diagnosis TEXT,
    treatment_plan TEXT,
    recommendations TEXT,
    
    -- Clinical Data
    vital_signs JSONB, -- {"blood_pressure": "120/80", "heart_rate": "72", "temperature": "37.0", ...}
    symptoms TEXT[],
    medications_prescribed TEXT[],
    
    -- File Attachments
    file_attachments JSONB, -- [{"name": "report.pdf", "url": "storage_url", "type": "pdf", "size": 1024}]
    
    -- Follow-up
    follow_up_required BOOLEAN DEFAULT FALSE,
    follow_up_date DATE,
    
    -- Privacy & Access
    is_confidential BOOLEAN DEFAULT FALSE,
    shared_with UUID[], -- Array of user IDs who have access
    
    -- Audit Fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- 6. PRESCRIPTIONS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.prescriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- References
    patient_id UUID NOT NULL REFERENCES public.users(id),
    doctor_id UUID NOT NULL REFERENCES public.doctors(id),
    appointment_id UUID REFERENCES public.appointments(id),
    medical_record_id UUID REFERENCES public.medical_records(id),
    
    -- Medication Details
    medication_name VARCHAR(200) NOT NULL,
    generic_name VARCHAR(200),
    dosage VARCHAR(100) NOT NULL,
    frequency VARCHAR(100) NOT NULL, -- "Once daily", "Twice daily", etc.
    duration VARCHAR(100) NOT NULL, -- "7 days", "2 weeks", etc.
    quantity_prescribed INTEGER,
    
    -- Instructions
    instructions TEXT NOT NULL,
    side_effects TEXT,
    precautions TEXT,
    
    -- Pharmacy & Refills
    pharmacy_instructions TEXT,
    refills_allowed INTEGER DEFAULT 0,
    refills_remaining INTEGER DEFAULT 0,
    
    -- Status & Dates
    status VARCHAR(20) DEFAULT 'active' CHECK (
        status IN ('active', 'completed', 'discontinued', 'expired')
    ),
    start_date DATE NOT NULL DEFAULT CURRENT_DATE,
    end_date DATE,
    expiry_date DATE,
    
    -- Audit Fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT valid_dates CHECK (
        end_date IS NULL OR end_date >= start_date
    ),
    CONSTRAINT valid_refills CHECK (
        refills_remaining <= refills_allowed
    )
);

-- ============================================================================
-- 7. LAB RESULTS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.lab_results (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- References
    patient_id UUID NOT NULL REFERENCES public.users(id),
    doctor_id UUID REFERENCES public.doctors(id),
    appointment_id UUID REFERENCES public.appointments(id),
    
    -- Test Information
    test_name VARCHAR(200) NOT NULL,
    test_type VARCHAR(100) NOT NULL, -- "blood", "urine", "imaging", etc.
    test_category VARCHAR(100), -- "routine", "diagnostic", "monitoring"
    
    -- Results
    results JSONB NOT NULL, -- Flexible structure for different test types
    normal_ranges JSONB,
    units JSONB,
    abnormal_flags TEXT[],
    
    -- Interpretation
    interpretation TEXT,
    recommendations TEXT,
    critical_values BOOLEAN DEFAULT FALSE,
    
    -- File Attachments
    file_attachments JSONB,
    
    -- Dates
    test_date DATE NOT NULL,
    result_date DATE NOT NULL,
    report_date DATE DEFAULT CURRENT_DATE,
    
    -- Status
    status VARCHAR(20) DEFAULT 'completed' CHECK (
        status IN ('ordered', 'in_progress', 'completed', 'cancelled')
    ),
    
    -- Audit Fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- 8. HEALTH ARTICLES TABLE (Dynamic Content)
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.health_articles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Content
    title VARCHAR(300) NOT NULL,
    summary TEXT,
    content TEXT NOT NULL,
    featured_image_url TEXT,
    
    -- Classification
    category VARCHAR(100) NOT NULL,
    tags TEXT[],
    target_audience VARCHAR(50) DEFAULT 'all' CHECK (
        target_audience IN ('all', 'students', 'staff', 'patients')
    ),
    
    -- Author & Publication
    author_id UUID REFERENCES public.users(id),
    author_name VARCHAR(200),
    reviewed_by UUID REFERENCES public.users(id),
    
    -- SEO & Metadata
    slug VARCHAR(300) UNIQUE,
    meta_description TEXT,
    read_time_minutes INTEGER,
    
    -- Engagement
    view_count INTEGER DEFAULT 0,
    like_count INTEGER DEFAULT 0,
    
    -- Publication Status
    status VARCHAR(20) DEFAULT 'draft' CHECK (
        status IN ('draft', 'published', 'archived')
    ),
    published_at TIMESTAMP WITH TIME ZONE,
    
    -- Audit Fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- 9. NOTIFICATIONS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Recipients
    user_id UUID NOT NULL REFERENCES public.users(id),
    sender_id UUID REFERENCES public.users(id),
    
    -- Content
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    notification_type VARCHAR(50) NOT NULL CHECK (
        notification_type IN ('appointment_reminder', 'appointment_confirmed', 
                             'appointment_cancelled', 'prescription_ready', 
                             'lab_results', 'health_tip', 'system_alert', 
                             'chat_message', 'emergency')
    ),
    
    -- Related Data
    related_entity_type VARCHAR(50), -- 'appointment', 'prescription', etc.
    related_entity_id UUID,
    
    -- Delivery
    delivery_methods TEXT[] DEFAULT ARRAY['in_app'], -- 'in_app', 'email', 'sms', 'push'
    scheduled_for TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Status
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP WITH TIME ZONE,
    is_sent BOOLEAN DEFAULT FALSE,
    sent_at TIMESTAMP WITH TIME ZONE,
    
    -- Priority
    priority VARCHAR(20) DEFAULT 'normal' CHECK (
        priority IN ('low', 'normal', 'high', 'urgent')
    ),
    
    -- Audit Fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- 10. ENHANCED CHAT SYSTEM
-- ============================================================================

-- Chat conversations/rooms
CREATE TABLE IF NOT EXISTS public.chats (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Participants
    patient_id UUID NOT NULL REFERENCES public.users(id),
    staff_id UUID REFERENCES public.users(id),
    
    -- Chat Details
    subject VARCHAR(200) NOT NULL,
    description TEXT,
    chat_type VARCHAR(20) DEFAULT 'consultation' CHECK (
        chat_type IN ('consultation', 'support', 'emergency', 'follow_up')
    ),
    
    -- Related Data
    appointment_id UUID REFERENCES public.appointments(id),
    medical_record_id UUID REFERENCES public.medical_records(id),
    
    -- Status
    status VARCHAR(20) DEFAULT 'active' CHECK (
        status IN ('active', 'closed', 'archived')
    ),
    closed_at TIMESTAMP WITH TIME ZONE,
    closed_by UUID REFERENCES public.users(id),
    
    -- Metadata
    priority VARCHAR(20) DEFAULT 'normal' CHECK (
        priority IN ('low', 'normal', 'high', 'urgent')
    ),
    
    -- Audit Fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Chat messages
CREATE TABLE IF NOT EXISTS public.chat_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- References
    chat_id UUID NOT NULL REFERENCES public.chats(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES public.users(id),
    
    -- Message Content
    message_type VARCHAR(20) DEFAULT 'text' CHECK (
        message_type IN ('text', 'image', 'file', 'voice', 'video', 'system')
    ),
    content TEXT,
    
    -- File Attachments
    file_attachments JSONB,
    
    -- Message Status
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP WITH TIME ZONE,
    is_edited BOOLEAN DEFAULT FALSE,
    edited_at TIMESTAMP WITH TIME ZONE,
    
    -- Reply/Thread
    reply_to UUID REFERENCES public.chat_messages(id),
    
    -- Audit Fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- 11. SYSTEM AUDIT LOG
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- User & Action
    user_id UUID REFERENCES public.users(id),
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID,
    
    -- Details
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    user_agent TEXT,
    
    -- Context
    session_id UUID,
    request_id UUID,
    
    -- Timestamp
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================================

-- Users table indexes
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON public.users(role);
CREATE INDEX IF NOT EXISTS idx_users_student_id ON public.users(student_id);
CREATE INDEX IF NOT EXISTS idx_users_staff_id ON public.users(staff_id);

-- Appointments table indexes
CREATE INDEX IF NOT EXISTS idx_appointments_patient_id ON public.appointments(patient_id);
CREATE INDEX IF NOT EXISTS idx_appointments_doctor_id ON public.appointments(doctor_id);
CREATE INDEX IF NOT EXISTS idx_appointments_date ON public.appointments(appointment_date);
CREATE INDEX IF NOT EXISTS idx_appointments_status ON public.appointments(status);

-- Medical records indexes
CREATE INDEX IF NOT EXISTS idx_medical_records_patient_id ON public.medical_records(patient_id);
CREATE INDEX IF NOT EXISTS idx_medical_records_type ON public.medical_records(record_type);
CREATE INDEX IF NOT EXISTS idx_medical_records_date ON public.medical_records(created_at);

-- Chat system indexes
CREATE INDEX IF NOT EXISTS idx_chats_patient_id ON public.chats(patient_id);
CREATE INDEX IF NOT EXISTS idx_chats_staff_id ON public.chats(staff_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_chat_id ON public.chat_messages(chat_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_sender_id ON public.chat_messages(sender_id);

-- Notifications indexes
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_type ON public.notifications(notification_type);
CREATE INDEX IF NOT EXISTS idx_notifications_unread ON public.notifications(user_id, is_read) WHERE is_read = FALSE;

-- ============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================

-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.departments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.doctors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.medical_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.prescriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lab_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.health_articles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

-- Users policies
CREATE POLICY "Users can view their own profile" ON public.users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);

-- Staff and admins can view all users
CREATE POLICY "Staff can view all users" ON public.users
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role IN ('staff', 'admin')
        )
    );

-- Appointments policies
CREATE POLICY "Patients can view their appointments" ON public.appointments
    FOR SELECT USING (
        patient_id = auth.uid() OR
        EXISTS (
            SELECT 1 FROM public.doctors d JOIN public.users u ON d.user_id = u.id
            WHERE d.id = doctor_id AND u.id = auth.uid()
        )
    );

CREATE POLICY "Patients can create appointments" ON public.appointments
    FOR INSERT WITH CHECK (patient_id = auth.uid());

-- Medical records policies
CREATE POLICY "Patients can view their medical records" ON public.medical_records
    FOR SELECT USING (
        patient_id = auth.uid() OR
        EXISTS (
            SELECT 1 FROM public.doctors d JOIN public.users u ON d.user_id = u.id
            WHERE d.id = doctor_id AND u.id = auth.uid()
        ) OR
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Chat policies
CREATE POLICY "Users can view their chats" ON public.chats
    FOR SELECT USING (
        patient_id = auth.uid() OR 
        staff_id = auth.uid() OR
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

CREATE POLICY "Users can view messages in their chats" ON public.chat_messages
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.chats c 
            WHERE c.id = chat_id AND (
                c.patient_id = auth.uid() OR 
                c.staff_id = auth.uid()
            )
        )
    );

-- Notifications policies
CREATE POLICY "Users can view their notifications" ON public.notifications
    FOR SELECT USING (user_id = auth.uid());

-- Public content policies
CREATE POLICY "All authenticated users can view published articles" ON public.health_articles
    FOR SELECT USING (status = 'published' AND auth.uid() IS NOT NULL);

CREATE POLICY "All authenticated users can view departments" ON public.departments
    FOR SELECT USING (is_active = TRUE AND auth.uid() IS NOT NULL);

CREATE POLICY "All authenticated users can view doctors" ON public.doctors
    FOR SELECT USING (is_available = TRUE AND auth.uid() IS NOT NULL);

-- ============================================================================
-- FUNCTIONS AND TRIGGERS
-- ============================================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply updated_at trigger to all relevant tables
CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON public.users 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_departments_updated_at 
    BEFORE UPDATE ON public.departments 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_doctors_updated_at 
    BEFORE UPDATE ON public.doctors 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_appointments_updated_at 
    BEFORE UPDATE ON public.appointments 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_medical_records_updated_at 
    BEFORE UPDATE ON public.medical_records 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_prescriptions_updated_at 
    BEFORE UPDATE ON public.prescriptions 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_lab_results_updated_at 
    BEFORE UPDATE ON public.lab_results 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_health_articles_updated_at 
    BEFORE UPDATE ON public.health_articles 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_notifications_updated_at 
    BEFORE UPDATE ON public.notifications 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_chats_updated_at 
    BEFORE UPDATE ON public.chats 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_chat_messages_updated_at 
    BEFORE UPDATE ON public.chat_messages 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- STORAGE BUCKETS
-- ============================================================================

-- Create storage buckets for file uploads
INSERT INTO storage.buckets (id, name, public) VALUES 
('profiles', 'profiles', true),
('medical-records', 'medical-records', false),
('prescriptions', 'prescriptions', false),
('lab-results', 'lab-results', false),
('chat-attachments', 'chat-attachments', false),
('health-articles', 'health-articles', true)
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- INITIAL DATA SEED
-- ============================================================================

-- Insert departments
INSERT INTO public.departments (id, name, description, location, phone_number, email, services, operating_hours) VALUES
(uuid_generate_v4(), 'General Practice', 'Primary healthcare services for students and staff', 'Health Center - Ground Floor', '+233-31-206-0001', 'general@umat.edu.gh', ARRAY['Consultations', 'Health Checkups', 'Vaccinations'], '{"monday": "08:00-17:00", "tuesday": "08:00-17:00", "wednesday": "08:00-17:00", "thursday": "08:00-17:00", "friday": "08:00-17:00"}'),
(uuid_generate_v4(), 'Mental Health', 'Counseling and psychological support services', 'Health Center - First Floor', '+233-31-206-0002', 'mental@umat.edu.gh', ARRAY['Counseling', 'Therapy', 'Crisis Intervention'], '{"monday": "09:00-16:00", "tuesday": "09:00-16:00", "wednesday": "09:00-16:00", "thursday": "09:00-16:00", "friday": "09:00-16:00"}'),
(uuid_generate_v4(), 'Emergency Care', '24/7 emergency medical services', 'Health Center - Emergency Wing', '+233-31-206-0911', 'emergency@umat.edu.gh', ARRAY['Emergency Treatment', 'First Aid', 'Ambulance Services'], '{"monday": "00:00-23:59", "tuesday": "00:00-23:59", "wednesday": "00:00-23:59", "thursday": "00:00-23:59", "friday": "00:00-23:59", "saturday": "00:00-23:59", "sunday": "00:00-23:59"}'),
(uuid_generate_v4(), 'Dental Care', 'Comprehensive dental services', 'Health Center - Dental Wing', '+233-31-206-0003', 'dental@umat.edu.gh', ARRAY['Cleanings', 'Fillings', 'Extractions', 'Oral Health'], '{"monday": "08:00-16:00", "tuesday": "08:00-16:00", "wednesday": "08:00-16:00", "thursday": "08:00-16:00", "friday": "08:00-16:00"}')
ON CONFLICT DO NOTHING;

-- Insert sample health articles
INSERT INTO public.health_articles (title, summary, content, category, tags, author_name, status, published_at, read_time_minutes) VALUES
('Managing Stress During Exam Season', 'Learn effective strategies to cope with academic stress and maintain mental well-being during exams.', 'Exam season can be overwhelming, but with the right strategies, you can manage stress effectively...', 'Mental Health', ARRAY['stress', 'exams', 'students', 'mental health'], 'Dr. Sarah Johnson', 'published', NOW(), 5),
('Healthy Eating on Campus', 'Tips for maintaining a balanced diet while living in university accommodation.', 'Eating healthy on campus doesn''t have to be difficult. Here are practical tips...', 'Nutrition', ARRAY['nutrition', 'diet', 'campus life', 'health'], 'Dr. Michael Chen', 'published', NOW(), 7),
('The Importance of Regular Exercise for Students', 'Discover how physical activity can improve your academic performance and overall health.', 'Regular exercise is crucial for students, not just for physical health...', 'Fitness', ARRAY['exercise', 'fitness', 'students', 'health'], 'Dr. Emily Davis', 'published', NOW(), 6)
ON CONFLICT DO NOTHING;

-- ============================================================================
-- COMPLETION MESSAGE
-- ============================================================================

-- Log completion
DO $$
BEGIN
    RAISE NOTICE '============================================================================';
    RAISE NOTICE 'U_CLINIC PREMIUM DATABASE SCHEMA SUCCESSFULLY CREATED!';
    RAISE NOTICE '============================================================================';
    RAISE NOTICE 'Tables Created: users, departments, doctors, appointments, medical_records,';
    RAISE NOTICE '                prescriptions, lab_results, health_articles, notifications,';
    RAISE NOTICE '                chats, chat_messages, audit_logs';
    RAISE NOTICE 'Features: RLS policies, indexes, triggers, storage buckets, initial data';
    RAISE NOTICE '============================================================================';
END $$;
