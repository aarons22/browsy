import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';

const app = express();
const PORT = process.env.PORT || 8080;

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
    service: 'browsy-backend'
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