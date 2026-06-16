import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class SeedingService {
  static Future<void> seedInitialData() async {
    try {
      final firestore = FirebaseFirestore.instance;
      
      // Check if data is already seeded by looking for a specific mock email
      final checkQuery = await firestore
          .collection('users')
          .where('email', isEqualTo: 'john.doe@exchange.edu')
          .limit(1)
          .get();
          
      if (checkQuery.docs.isNotEmpty) {
        debugPrint('SeedingService: Database is already seeded.');
        return;
      }
      
      debugPrint('SeedingService: Seeding initial student experts data...');
      
      // Define departments and subskills with levels
      final List<Map<String, dynamic>> seedData = [
        // 1. Programming
        {
          'userId': 'mock_user_prog_beg',
          'name': 'John Doe',
          'email': 'john.doe@exchange.edu',
          'category': 'Programming',
          'skillName': 'Python Basics',
          'level': 'Beginner',
          'price': '15000',
          'rating': 4.2,
          'exp': 1,
          'bio': 'Computer Science freshman eager to help peers with python loops, basic data structures, and debug errors.',
          'avatar': 'https://i.pravatar.cc/150?img=11',
        },
        {
          'userId': 'mock_user_prog_int',
          'name': 'Sarah Connor',
          'email': 'sarah.connor@exchange.edu',
          'category': 'Programming',
          'skillName': 'Flutter Development',
          'level': 'Intermediate',
          'price': '45000',
          'rating': 4.7,
          'exp': 3,
          'bio': 'Third year student. I build sleek cross-platform apps using Flutter and Firebase. Happy to assist with UI layouts or stream builders!',
          'avatar': 'https://i.pravatar.cc/150?img=5',
        },
        {
          'userId': 'mock_user_prog_exp',
          'name': 'David Webb',
          'email': 'david.webb@exchange.edu',
          'category': 'Programming',
          'skillName': 'Java Development',
          'level': 'Expert',
          'price': '90000',
          'rating': 5.0,
          'exp': 5,
          'bio': 'Senior software engineering student. Deep understanding of backend engineering, microservices, and databases in Java/Spring Boot.',
          'avatar': 'https://i.pravatar.cc/150?img=8',
        },
        // 2. IT
        {
          'userId': 'mock_user_it_beg',
          'name': 'Alex Mercer',
          'email': 'alex.mercer@exchange.edu',
          'category': 'IT',
          'skillName': 'PC Hardware Setup',
          'level': 'Beginner',
          'price': '20000',
          'rating': 4.0,
          'exp': 1,
          'bio': 'I help setup operating systems, build gaming rigs, clean dust from laptops, and apply fresh thermal paste.',
          'avatar': 'https://i.pravatar.cc/150?img=12',
        },
        {
          'userId': 'mock_user_it_int',
          'name': 'Elena Fisher',
          'email': 'elena.fisher@exchange.edu',
          'category': 'IT',
          'skillName': 'Network Administration',
          'level': 'Intermediate',
          'price': '50000',
          'rating': 4.6,
          'exp': 2,
          'bio': 'Passionate about networks. I can assist with router configurations, subnetting, DHCP setup, and basic packet tracing.',
          'avatar': 'https://i.pravatar.cc/150?img=9',
        },
        {
          'userId': 'mock_user_it_exp',
          'name': 'Victor Sullivan',
          'email': 'victor.sullivan@exchange.edu',
          'category': 'IT',
          'skillName': 'Cloud Infrastructure',
          'level': 'Expert',
          'price': '100000',
          'rating': 4.9,
          'exp': 4,
          'bio': 'AWS Certified solutions architect student. I manage cloud pipelines, deploy Docker containers, and optimize server bills.',
          'avatar': 'https://i.pravatar.cc/150?img=3',
        },
        // 3. Design
        {
          'userId': 'mock_user_des_beg',
          'name': 'Peter Parker',
          'email': 'peter.parker@exchange.edu',
          'category': 'Design',
          'skillName': 'Canva Design',
          'level': 'Beginner',
          'price': '10000',
          'rating': 4.3,
          'exp': 1,
          'bio': 'Can create quick visual graphics, social media posts, posters, and presentation slides using Canva templates.',
          'avatar': 'https://i.pravatar.cc/150?img=4',
        },
        {
          'userId': 'mock_user_des_int',
          'name': 'Gwen Stacy',
          'email': 'gwen.stacy@exchange.edu',
          'category': 'Design',
          'skillName': 'UI/UX Design',
          'level': 'Intermediate',
          'price': '40000',
          'rating': 4.8,
          'exp': 3,
          'bio': 'I design user journeys and high-fidelity wireframes in Figma. Let\'s make your mobile or web app look stunning!',
          'avatar': 'https://i.pravatar.cc/150?img=1',
        },
        {
          'userId': 'mock_user_des_exp',
          'name': 'Bruce Wayne',
          'email': 'bruce.wayne@exchange.edu',
          'category': 'Design',
          'skillName': 'Brand Identity Design',
          'level': 'Expert',
          'price': '120000',
          'rating': 5.0,
          'exp': 4,
          'bio': 'Professional branding designer. I create bespoke logos, typography systems, vector mockups, and corporate visual standards.',
          'avatar': 'https://i.pravatar.cc/150?img=6',
        },
        // 4. Multimedia
        {
          'userId': 'mock_user_mul_beg',
          'name': 'Clark Kent',
          'email': 'clark.kent@exchange.edu',
          'category': 'Multimedia',
          'skillName': 'Photo Retouching',
          'level': 'Beginner',
          'price': '12000',
          'rating': 4.1,
          'exp': 1,
          'bio': 'I remove backgrounds, retouch portrait lighting, adjust colors, and optimize images in Photoshop.',
          'avatar': 'https://i.pravatar.cc/150?img=7',
        },
        {
          'userId': 'mock_user_mul_int',
          'name': 'Lois Lane',
          'email': 'lois.lane@exchange.edu',
          'category': 'Multimedia',
          'skillName': 'Video Editing',
          'level': 'Intermediate',
          'price': '35000',
          'rating': 4.6,
          'exp': 2,
          'bio': 'Edit event highlights, TikToks, presentations, and tutorials. I cut footage, add sound effects, and sync music.',
          'avatar': 'https://i.pravatar.cc/150?img=2',
        },
        {
          'userId': 'mock_user_mul_exp',
          'name': 'Tony Stark',
          'email': 'tony.stark@exchange.edu',
          'category': 'Multimedia',
          'skillName': '3D Animation',
          'level': 'Expert',
          'price': '150000',
          'rating': 4.9,
          'exp': 5,
          'bio': '3D modelling and animation specialist in Blender. Experienced in rendering architectural walks, asset modeling, and motion graphics.',
          'avatar': 'https://i.pravatar.cc/150?img=10',
        },
        // 5. Security
        {
          'userId': 'mock_user_sec_beg',
          'name': 'Bruce Banner',
          'email': 'bruce.banner@exchange.edu',
          'category': 'Security',
          'skillName': 'Basic Cyber Hygiene',
          'level': 'Beginner',
          'price': '25000',
          'rating': 4.4,
          'exp': 1,
          'bio': 'Learn how to secure your local router, choose strong passwords, handle phishing emails, and keep your Windows/Mac safe.',
          'avatar': 'https://i.pravatar.cc/150?img=13',
        },
        {
          'userId': 'mock_user_sec_int',
          'name': 'Natasha Romanoff',
          'email': 'natasha.romanoff@exchange.edu',
          'category': 'Security',
          'skillName': 'Ethical Hacking',
          'level': 'Intermediate',
          'price': '60000',
          'rating': 4.8,
          'exp': 3,
          'bio': 'I practice network penetration testing and analyze code exploits. Certified in CEH concepts, ready to review your network setup.',
          'avatar': 'https://i.pravatar.cc/150?img=14',
        },
        {
          'userId': 'mock_user_sec_exp',
          'name': 'Nick Fury',
          'email': 'nick.fury@exchange.edu',
          'category': 'Security',
          'skillName': 'Penetration Testing',
          'level': 'Expert',
          'price': '180000',
          'rating': 5.0,
          'exp': 4,
          'bio': 'Specialist in security auditing, firewall configuration, intrusion detection, and incident response planning.',
          'avatar': 'https://i.pravatar.cc/150?img=15',
        },
      ];
      
      final batch = firestore.batch();
      
      for (final doc in seedData) {
        final userId = doc['userId'];
        
        // 1. Create User Document
        final userRef = firestore.collection('users').doc(userId);
        batch.set(userRef, {
          'id': userId,
          'name': doc['name'],
          'email': doc['email'],
          'role': 'student',
          'isVerified': true,
          'subSkills': [doc['skillName']],
          'portfolioUrls': [],
          'completedJobs': 5,
          'rating': doc['rating'],
          'endorsements': [],
          'profileImageUrl': doc['avatar'],
          'reviews': 3,
          'hostingYears': 1,
          'walletBalance': 80000.0,
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        // 2. Create Skill Document
        final skillId = 'skill_$userId';
        final skillRef = firestore.collection('skills').doc(skillId);
        batch.set(skillRef, {
          'name': doc['skillName'],
          'description': doc['bio'],
          'category': doc['category'],
          'userIds': [userId],
          'instructorId': userId,
          'instructorPhotoUrl': doc['avatar'],
          'instructorName': doc['name'],
          'rating': doc['rating'],
          'reviews': 3,
          'pricePerLesson': doc['price'],
          'country': 'Uganda',
          'flag': '🇺🇬',
          'lessons': doc['exp'] * 12,
          'experienceYears': doc['exp'],
          'bio': doc['bio'],
          'tags': [doc['category'], doc['skillName'], doc['level']],
          'coverImageUrl': 'https://picsum.photos/seed/$userId/800/400',
          'level': doc['level'],
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      
      await batch.commit();
      debugPrint('SeedingService: Successfully seeded 15 student experts.');
      
    } catch (e) {
      debugPrint('SeedingService Error: $e');
    }
  }
}
