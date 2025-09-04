# 🎥 **VIDEO CALL TESTING GUIDE**

## **How to Test Real Video Calls Between Doctor and Patient**

### **📱 For Patients:**

1. **Login as a patient** (e.g., Chris or any patient account)
2. **Go to Patient Dashboard**
3. **Look for "LIVE" badge** on today's appointments
4. **Click "Join Video Call"** button when appointment is active
5. **Enter the same consultation room** as the doctor

### **👩‍⚕️ For Doctors/Staff:**

1. **Login as Emily** (staff/doctor account)
2. **Go to Today's Schedule**
3. **Click "Start"** on any appointment
4. **Wait for patient to join** the same channel

### **🔗 How Video Calls Work:**

- **Same Channel Name**: Both doctor and patient join `consultation_{appointment_id}`
- **Real-time Video**: Agora RTC Engine provides actual video streaming
- **Call Controls**: Mute, video toggle, end call functionality
- **Chat Integration**: Real-time chat alongside video call
- **Notes**: Consultation notes for medical documentation

### **⏰ Timing:**

- **Appointments show "LIVE"** when within 30 minutes of scheduled time
- **Video call buttons appear** only during active appointment windows
- **Both participants must join** the same channel to see each other

### **🎯 Testing Steps:**

1. **Doctor starts call** → Joins channel `consultation_5e6e8d5f-3cbc-416c-8da1-b5b9c6da4e4e`
2. **Patient sees "LIVE" badge** → Clicks "Join Video Call"
3. **Patient joins same channel** → Real video connection established
4. **Both see each other** → Full video call with controls
5. **Chat and notes available** → Complete consultation experience

### **🔧 Technical Details:**

- **Agora RTC Engine**: Industry-standard video calling
- **Channel-based**: Each appointment gets unique channel
- **Real-time**: Actual video/audio streaming
- **Cross-platform**: Works on mobile and web
- **Professional**: Production-ready video calling

### **📞 Support:**

If video calls don't work:
1. Check internet connection
2. Ensure both users join same channel
3. Verify appointment timing (within 30 minutes)
4. Check camera/microphone permissions

---

**🎉 You now have REAL video calling between patients and doctors!**
