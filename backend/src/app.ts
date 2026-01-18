import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import { initializeApp, applicationDefault } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import dotenv from 'dotenv';

// Routes
import shelvesRoutes from './routes/shelves';

// Load environment variables
dotenv.config();

// Initialize Firebase Admin SDK
// In production, this will use Application Default Credentials
// In development, set GOOGLE_APPLICATION_CREDENTIALS environment variable
initializeApp({
  credential: applicationDefault(),
  projectId: process.env.FIREBASE_PROJECT_ID || process.env.GOOGLE_CLOUD_PROJECT,
});

const db = getFirestore();

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
      initialized: true,
      projectId: process.env.FIREBASE_PROJECT_ID || process.env.GOOGLE_CLOUD_PROJECT || 'not-configured'
    }
  });
});

// Root endpoint
app.get('/', (_req, res) => {
  res.status(200).json({
    message: 'Browsy Backend API',
    version: '1.0.0',
    endpoints: {
      health: '/health',
      shelves: '/api/shelves'
    }
  });
});

// API Routes
app.use('/api/shelves', shelvesRoutes);

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Browsy backend server started on port ${PORT}`);
  console.log(`📋 Health check available at: http://localhost:${PORT}/health`);
});

export default app;
export { db };