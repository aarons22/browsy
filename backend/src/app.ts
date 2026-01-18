import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import admin from 'firebase-admin';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

// Initialize Firebase Admin SDK
// In production, this will use Application Default Credentials
// In development, set GOOGLE_APPLICATION_CREDENTIALS environment variable
if (!admin.apps.length) {
  admin.initializeApp({
    projectId: process.env.FIREBASE_PROJECT_ID || process.env.GOOGLE_CLOUD_PROJECT,
  });
}

const app = express();
const PORT = process.env.PORT || 3001;

// Security middleware
app.use(helmet());
app.use(cors());
app.use(compression());

// Body parsing middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check endpoint
app.get('/health', (_req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    service: 'browsy-backend',
    firebase: {
      initialized: admin.apps.length > 0,
      projectId: admin.apps[0]?.options.projectId || 'not-configured'
    }
  });
});

// Root endpoint
app.get('/', (_req, res) => {
  res.status(200).json({
    message: 'Browsy Backend API',
    version: '1.0.0',
    endpoints: {
      health: '/health'
    }
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Browsy backend server started on port ${PORT}`);
  console.log(`📋 Health check available at: http://localhost:${PORT}/health`);
});

export default app;