# u_clinic

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

    RAISE NOTICE '============================================================================';
    RAISE NOTICE 'DOCTOR ACCOUNT CREATION INSTRUCTIONS';
    RAISE NOTICE '============================================================================';
    RAISE NOTICE 'Step 1: Create these doctor accounts in Supabase Auth (Dashboard > Authentication > Users):';
    RAISE NOTICE '1. Email: dr.sarah@umat.edu.gh, Password: UmatDoc123!, Role: staff';
    RAISE NOTICE '2. Email: dr.michael@umat.edu.gh, Password: UmatDoc123!, Role: staff';  
    RAISE NOTICE '3. Email: dr.emily@umat.edu.gh, Password: UmatDoc123!, Role: staff';
    RAISE NOTICE '4. Email: dr.emmanuel@umat.edu.gh, Password: UmatDoc123!, Role: staff';
    RAISE NOTICE '';
    RAISE NOTICE 'Step 2: After creating users, note their User IDs and run update_doctor_accounts.sql';
    RAISE NOTICE '============================================================================';

    RAISE NOTICE 'Also create admin account: admin@umat.edu.gh with password UmatAdmin123!';