import 'package:flutter/material.dart';

class GameConstants {
  // =============================================
  // ✅ أبعاد اللاعب
  // =============================================
  static const double playerWidth = 55;
  static const double playerHeight = 55;
  static const double playerX = 60;

  // =============================================
  // ✅ الفيزياء
  // =============================================
  static const double gravity = 0.75;
  static const double jumpForce = -18;
  static const double initialSpeed = 8;
  static const double maxSpeed = 22;

  // =============================================
  // ✅ الأبعاد
  // =============================================
  static const double groundRatio = 0.80;
  static const int fps = 60;
  static const double frameTime = 1.0 / fps;

  // =============================================
  // ✅ الألوان
  // =============================================
  static const Color primaryColor = Color(0xFF0D6EFD);
  static const Color secondaryColor = Color(0xFFFFC107);
  static const Color successColor = Color(0xFF198754);
  static const Color dangerColor = Color(0xFFDC3545);
  static const Color darkColor = Color(0xFF1A1A2E);
  static const Color grayColor = Color(0xFF6C757D);

  // =============================================
  // ✅ الصعوبة
  // =============================================
  static const Map<int, Map<String, dynamic>> difficultySettings = {
    1: {
      'initialSpeed': 4.5,
      'maxSpeed': 9.0,
      'speedIncrement': 0.08,
      'gapChance': 0.15,
      'bumpChance': 0.15,
      'birdChance': 0.20,
      'obstacleDistanceMin': 500,
      'obstacleDistanceMax': 900,
      'groundFeatureMin': 1800,
      'groundFeatureMax': 3000,
      'zombieChance': 0.0,
    },
    2: {
      'initialSpeed': 5.5,
      'maxSpeed': 11.0,
      'speedIncrement': 0.12,
      'gapChance': 0.12,
      'bumpChance': 0.12,
      'birdChance': 0.25,
      'obstacleDistanceMin': 400,
      'obstacleDistanceMax': 800,
      'groundFeatureMin': 1500,
      'groundFeatureMax': 2500,
      'zombieChance': 0.10,
    },
    3: {
      'initialSpeed': 6.5,
      'maxSpeed': 13.0,
      'speedIncrement': 0.15,
      'gapChance': 0.10,
      'bumpChance': 0.10,
      'birdChance': 0.30,
      'obstacleDistanceMin': 350,
      'obstacleDistanceMax': 650,
      'groundFeatureMin': 1200,
      'groundFeatureMax': 2000,
      'zombieChance': 0.20,
    },
    4: {
      'initialSpeed': 7.5,
      'maxSpeed': 15.0,
      'speedIncrement': 0.20,
      'gapChance': 0.08,
      'bumpChance': 0.08,
      'birdChance': 0.35,
      'obstacleDistanceMin': 300,
      'obstacleDistanceMax': 550,
      'groundFeatureMin': 1000,
      'groundFeatureMax': 1600,
      'zombieChance': 0.35,
    },
    5: {
      'initialSpeed': 8.5,
      'maxSpeed': 17.0,
      'speedIncrement': 0.25,
      'gapChance': 0.06,
      'bumpChance': 0.06,
      'birdChance': 0.40,
      'obstacleDistanceMin': 250,
      'obstacleDistanceMax': 450,
      'groundFeatureMin': 800,
      'groundFeatureMax': 1300,
      'zombieChance': 0.50,
    },
  };
}