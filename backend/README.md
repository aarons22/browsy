# Browsy Backend

Node.js Express backend with Firebase integration for the Browsy mobile app.

## Development Setup

1. Install dependencies:
   ```bash
   npm install
   ```

2. Configure environment variables in `.env`:
   ```
   FIREBASE_PROJECT_ID=your-project-id
   GOOGLE_APPLICATION_CREDENTIALS=./path/to/service-account.json
   PORT=3001
   ```

3. Start the development server:
   ```bash
   npm run dev
   ```

## Configuration

- **Port**: Defaults to 3001 (configurable via `PORT` environment variable)
- **Firebase**: Requires valid Firebase project ID and service account credentials

## Endpoints

- `GET /` - API information
- `GET /health` - Health check with Firebase status

## Deployment

The backend is containerized and ready for deployment to Google Cloud Run.