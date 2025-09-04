# Supabase Setup and Configuration

## Current Status
- ✅ Supabase project created and configured
- ✅ Flutter app configured with Supabase credentials
- ✅ Authentication repository implemented with comprehensive terminal logging
- ✅ Simplified sign-in/sign-up screens (no debug screens)
- 🔄 Testing authentication flow and user creation
- ❌ **ISSUE FOUND**: Infinite recursion in RLS policies

## Critical Issue: Infinite Recursion in RLS Policies

### Problem
The debug screen showed: `PostgrestException: infinite recursion detected in policy for relation "users"`

### Root Cause
The Row Level Security (RLS) policies on the `users` table are creating a circular reference, causing infinite recursion when trying to access the table.

### Solution

#### Option 1: Quick Fix (Recommended for Testing)
1. Go to Supabase Dashboard → SQL Editor
2. Run this command:
```sql
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
```
3. Test the connection again in your app

#### Option 2: Proper Fix (Recommended for Production)
1. Go to Supabase Dashboard → SQL Editor
2. Run the `fix_supabase_simple.sql` script which:
   - Disables RLS temporarily
   - Drops problematic policies
   - Creates simple, non-recursive policies
   - Re-enables RLS

#### Option 3: Disable Email Confirmation
1. Go to Supabase Dashboard → Authentication → Settings → Email Auth
2. Set "Confirm email" to OFF
3. This allows immediate sign-in after sign-up

## Simplified Authentication Flow

### What We've Done
- ✅ **Removed debug screens** - all logging now shows in terminal
- ✅ **Simplified auth repository** - cleaner, more focused code
- ✅ **Added terminal logging** - see all auth operations in Flutter console
- ✅ **Fixed sign-in screen** - proper role selection and validation

### Terminal Logging
All authentication operations now log to the terminal with emojis:
- 🔐 Sign in attempts
- 🚀 Sign up process
- 📧 Auth responses
- 📊 Database operations
- ✅ Success confirmations
- ❌ Error details

### Next Steps
1. **Fix the RLS issue** using one of the SQL scripts above
2. **Disable email confirmation** in Supabase dashboard
3. **Test sign-up and sign-in** - should work immediately
4. **Check terminal logs** for detailed operation information

## Project Configuration
- **Project URL**: https://fnznrjzzdgrhyhrkgfhb.supabase.co
- **Anon Key**: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZuem5yanp6ZGdyaHlocmtnZmhiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3MDc2MjksImV4cCI6MjA3MTI4MzYyOX0.Do90iMqnLmo6Orw-htT6Zq3Zw5roAu_3jPPGsscznp0

## Database Schema

### Users Table
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  email TEXT NOT NULL,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  student_id TEXT,
  staff_id TEXT,
  department TEXT,
  profile_image_url TEXT,
  date_of_birth DATE,
  gender TEXT,
  blood_type TEXT,
  emergency_contact_name TEXT,
  emergency_contact_phone TEXT,
  emergency_contact_relationship TEXT,
  presenting_symptoms TEXT[] DEFAULT '{}',
  medical_conditions TEXT[] DEFAULT '{}',
  allergies TEXT[] DEFAULT '{}',
  current_medications TEXT[] DEFAULT '{}',
  role TEXT NOT NULL DEFAULT 'patient',
  is_active BOOLEAN DEFAULT true,
  is_email_verified BOOLEAN DEFAULT false,
  is_phone_verified BOOLEAN DEFAULT false,
  two_factor_enabled BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## Row Level Security (RLS) Policies

### Users Table Policies
```sql
-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Users can read their own profile
CREATE POLICY "Users can view own profile" ON users
  FOR SELECT USING (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile" ON users
  FOR UPDATE USING (auth.uid() = id);

-- Allow insert during signup
CREATE POLICY "Allow insert during signup" ON users
  FOR INSERT WITH CHECK (auth.uid() = id);
```

## Authentication Flow

### Sign Up Process
1. User submits sign-up form
2. Supabase Auth creates user account
3. User profile is created in `users` table
4. Email confirmation is sent (if enabled)
5. User is redirected to appropriate dashboard

### Sign In Process
1. User submits sign-in form
2. Supabase Auth validates credentials
3. User profile is retrieved from `users` table
4. User is redirected to appropriate dashboard

## Debugging

### Debug Authentication Screen
- Access via `/debug-auth` route
- Test connection, sign up, sign in, and sign out
- View detailed logs in real-time
- Available only in debug mode

### Logging
The authentication repository includes comprehensive logging:
- 🔐 Sign in attempts
- 🚀 Sign up attempts
- 📧 Auth responses
- 📊 Database operations
- ❌ Error messages
- ✅ Success confirmations

### Common Issues and Solutions

#### 1. User Created but Not in Database
**Symptoms**: User appears signed up but profile not found
**Causes**: 
- Database insert failed
- RLS policies blocking insert
- Schema mismatch

**Solutions**:
- Check RLS policies
- Verify database schema
- Review error logs

#### 2. Email Confirmation Required
**Symptoms**: Sign up succeeds but no session
**Causes**: Email confirmation enabled in Supabase settings

**Solutions**:
- Check Supabase Auth settings
- Disable email confirmation for testing
- Handle confirmation flow in app

#### 3. Database Connection Issues
**Symptoms**: Connection timeouts or errors
**Causes**:
- Network issues
- Incorrect credentials
- Database not accessible

**Solutions**:
- Verify Supabase URL and key
- Check network connectivity
- Test with debug screen

## Testing Steps

1. **Test Connection**
   - Use debug screen to test database connection
   - Verify Supabase client initialization

2. **Test Sign Up**
   - Create new user account
   - Verify user appears in Supabase Auth
   - Verify user profile created in database

3. **Test Sign In**
   - Sign in with created account
   - Verify session creation
   - Verify profile retrieval

4. **Test Sign Out**
   - Sign out user
   - Verify session termination

## Next Steps

1. ✅ Implement comprehensive logging
2. ✅ Create debug authentication screen
3. 🔄 Test authentication flow
4. ⏳ Verify user creation in Supabase
5. ⏳ Test email confirmation flow
6. ⏳ Implement error handling improvements
7. ⏳ Add user profile management
8. ⏳ Implement password reset functionality

## Troubleshooting

### Check Supabase Dashboard
1. Go to https://supabase.com/dashboard
2. Select your project
3. Check Authentication > Users
4. Check Database > Tables > users

### Check Logs
- Use debug screen in app
- Check Flutter console output
- Review Supabase logs in dashboard

### Common Commands
```bash
# Run app in debug mode
flutter run --debug

# Check for errors
flutter analyze

# Clean and rebuild
flutter clean && flutter pub get
```
