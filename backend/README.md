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
- `POST /api/shelves/:userId/:shelfType` - Add book to user shelf
- `DELETE /api/shelves/:userId/:shelfType/:bookId` - Remove book from shelf
- `GET /api/shelves/:userId/:shelfType` - Get books in user shelf

## Deployment

**Current approach:** Firebase Functions (serverless, auto-scaling)
```bash
firebase deploy --only functions
```

**Future scaling option:** If serverless limits become restrictive, the codebase can be containerized with Docker for deployment to Cloud Run or other container platforms. The Express.js architecture is already compatible with both approaches.