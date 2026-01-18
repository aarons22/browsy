import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import { getFirestore } from 'firebase-admin/firestore';

// Routes
import shelvesRoutes from './routes/shelves';

const db = getFirestore();

const app = express();

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
      projectId: process.env.GCLOUD_PROJECT || 'not-configured'
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

export default app;
export { db };