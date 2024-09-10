class BookingRules {
  static List<Map<String, dynamic>> rules = [
    {
      'title': 'Booking Availability',
      'rules': [
        'Boxes can be booked for hourly slots during available hours.',
        'Only available boxes can be booked; once a box is booked, it cannot be double-booked for the same slot.',
      ],
    },
    {
      'title': 'Booking Duration',
      'rules': [
        'Minimum booking duration is 1 hour.',
        'Maximum booking duration is 3 hours per session. If you need more time, you must make a separate booking.',
      ],
    },
    {
      'title': 'Booking Confirmation',
      'rules': [
        'Bookings must be confirmed via payment within 15 minutes of selecting a time slot. Unpaid bookings will be automatically canceled.',
      ],
    },
    {
      'title': 'Cancellation Policy',
      'rules': [
        'Bookings can be canceled up to 24 hours before the scheduled time for a full refund.',
        'Cancellations made within 24 hours of the booking time will not be refunded.',
      ],
    },
    {
      'title': 'Late Arrival',
      'rules': [
        'If you arrive more than 15 minutes late, your booking may be forfeited, and the box may be reassigned to another user.',
        'No refunds will be issued for late arrivals or no-shows.',
      ],
    },
    {
      'title': 'Box Usage',
      'rules': [
        'Please adhere to the allotted time. Exceeding your booked time may incur additional charges.',
        'Keep the box clean and tidy. Any damage or excessive mess may result in additional cleaning or repair charges.',
      ],
    },
    {
      'title': 'Code of Conduct',
      'rules': [
        'Respect other players and maintain good sportsmanship at all times.',
        'Any form of misconduct, including abusive language or behavior, will result in immediate termination of the booking without a refund.',
      ],
    },
    {
      'title': 'Safety Rules',
      'rules': [
        'Proper cricket gear must be worn at all times.',
        'Follow all safety guidelines and instructions provided by the facility.',
      ],
    },
    {
      'title': 'Facility Rules',
      'rules': [
        'No food or drinks (except water) are allowed inside the cricket box.',
        'Smoking and alcohol consumption are strictly prohibited on the premises.',
      ],
    },
    {
      'title': 'Dispute Resolution',
      'rules': [
        'In case of any disputes, please contact the facility management immediately. Decisions made by management are final and binding.',
      ],
    },
  ];
}
