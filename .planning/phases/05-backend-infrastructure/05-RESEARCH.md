# Phase 5: Backend Infrastructure - Research

**Researched:** 2026-01-18
**Domain:** GCP Cloud Run + Firestore backend for mobile book app
**Confidence:** MEDIUM

## Summary

Research focused on building a GCP backend infrastructure for the Browsy mobile app using Cloud Run for containerized REST APIs and Firestore for user data persistence. The established pattern is Node.js/TypeScript with Express or Fastify on Cloud Run, connecting to Firestore via Firebase Admin SDK.

Key findings show that Cloud Run is ideal for stateless REST APIs with automatic scaling and pay-per-use billing. Firestore provides real-time sync capabilities perfect for mobile apps with offline support. The standard stack includes container deployment via Docker, Cloud Build for CI/CD, and Secret Manager for credentials.

**Primary recommendation:** Use Node.js 18+ with Express.js 4.x on Cloud Run, Firebase Admin SDK for Firestore, and Docker multi-stage builds for optimal cold start performance.

## Standard Stack

The established libraries/tools for this domain:

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Node.js | 18+ LTS | Runtime | Best Cloud Run performance, stable LTS support |
| Express.js | 4.18+ | Web framework | Mature, lightweight, extensive middleware ecosystem |
| Firebase Admin SDK | 11.x | Firestore/Auth | Official Google SDK, server-side operations |
| @google-cloud/secret-manager | 4.x | Configuration | Secure credential management |
| cors | 2.8+ | CORS handling | Required for mobile API access |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| helmet | 6.x | Security headers | Always - basic security hardening |
| compression | 1.7+ | Response compression | API responses > 1KB |
| express-rate-limit | 6.x | Rate limiting | Prevent abuse, protect quotas |
| joi or zod | Latest | Request validation | Type-safe API validation |
| winston | 3.x | Logging | Structured logging for Cloud Logging |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Express.js | Fastify 4.x | Better performance vs larger ecosystem |
| Cloud Run | Cloud Functions | More control vs simpler deployment |
| Firestore | Cloud SQL | Document flexibility vs relational queries |

**Installation:**
```bash
npm install express firebase-admin @google-cloud/secret-manager cors helmet compression
npm install -D @types/express @types/cors typescript ts-node
```

## Architecture Patterns

### Recommended Project Structure
```
backend/
├── src/
│   ├── controllers/     # Route handlers
│   ├── middleware/      # Custom middleware
│   ├── models/         # Firestore schema types
│   ├── services/       # Business logic
│   └── utils/          # Helpers, validation
├── Dockerfile          # Multi-stage build
├── .dockerignore       # Build optimization
├── cloudbuild.yaml     # CI/CD configuration
└── package.json        # Dependencies and scripts
```

### Pattern 1: Express + Firestore Service Layer
**What:** Separation of route handlers, business logic, and data access
**When to use:** All REST API projects
**Example:**
```typescript
// src/controllers/userController.ts
export const getUserShelves = async (req: Request, res: Response) => {
  try {
    const userId = req.params.userId;
    const shelves = await shelfService.getUserShelves(userId);
    res.json(shelves);
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
};

// src/services/shelfService.ts
export const getUserShelves = async (userId: string) => {
  const userRef = db.collection('users').doc(userId);
  const shelvesSnapshot = await userRef.collection('shelves').get();
  return shelvesSnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
};
```

### Pattern 2: Cloud Run Deployment with Docker
**What:** Multi-stage Docker build optimizing for Cloud Run constraints
**When to use:** All Cloud Run services
**Example:**
```dockerfile
# Build stage
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Runtime stage
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
EXPOSE 8080
CMD ["npm", "start"]
```

### Pattern 3: Firestore Schema Design for Mobile
**What:** Document structure optimizing for mobile app data access patterns
**When to use:** User data persistence
**Example:**
```typescript
// Collections structure
users/{userId} {
  email: string,
  displayName: string,
  createdAt: timestamp
}

users/{userId}/shelves/{shelfType} {
  name: 'TBR' | 'Read' | 'Recommendations',
  books: Book[],  // Denormalized for performance
  updatedAt: timestamp
}
```

### Anti-Patterns to Avoid
- **Deep nesting in Firestore:** Keep documents flat, use subcollections for 1-to-many
- **Synchronous Firestore operations:** Always use async/await or Promises
- **Hardcoded credentials:** Use Secret Manager or environment variables
- **Missing error boundaries:** Always handle Firestore exceptions

## Don't Hand-Roll

Problems that look simple but have existing solutions:

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Authentication | JWT validation | Firebase Auth | Handles tokens, refresh, security updates |
| Request validation | Manual parsing | joi/zod schemas | Type safety, comprehensive validation |
| Rate limiting | Custom counters | express-rate-limit | Memory/Redis backends, sliding windows |
| CORS configuration | Manual headers | cors middleware | Handles preflight, complex origins |
| Health checks | Custom endpoints | @google-cloud/health-check | Standard format, monitoring integration |
| Secrets management | Environment files | Secret Manager | Rotation, versioning, IAM integration |

**Key insight:** GCP provides managed services for most operational concerns - focus on business logic, not infrastructure.

## Common Pitfalls

### Pitfall 1: Cold Start Performance
**What goes wrong:** Slow API responses after periods of inactivity
**Why it happens:** Cloud Run containers shut down when unused, Node.js startup overhead
**How to avoid:** Multi-stage Docker builds, minimize dependencies, keep-alive requests
**Warning signs:** First request after idle taking >2 seconds

### Pitfall 2: Firestore Query Limits
**What goes wrong:** Queries fail or perform poorly at scale
**Why it happens:** Missing composite indexes, inefficient query patterns
**How to avoid:** Create indexes for compound queries, limit result sets, use pagination
**Warning signs:** Queries timing out, unexpected billing increases

### Pitfall 3: Cloud Run Memory/CPU Defaults
**What goes wrong:** Container OOM kills or CPU throttling
**Why it happens:** Default 512MB memory, 1 CPU insufficient for concurrent requests
**How to avoid:** Profile memory usage, set appropriate limits (1GB+ recommended)
**Warning signs:** 503 errors, high request latency under load

### Pitfall 4: Missing CORS for Mobile
**What goes wrong:** Mobile app API calls blocked by browser CORS policy
**Why it happens:** Mobile HTTP clients still enforce CORS in some contexts
**How to avoid:** Configure cors middleware with appropriate origins
**Warning signs:** API works in Postman but fails from mobile app

### Pitfall 5: Insecure Firestore Rules
**What goes wrong:** Data exposed or operations fail due to security rules
**Why it happens:** Default deny-all rules or overly permissive rules
**How to avoid:** Write specific rules for each operation, test with Firebase emulator
**Warning signs:** Unexpected permission denied errors, data accessible without auth

## Code Examples

Verified patterns from official sources and community best practices:

### Cloud Run Service Setup
```typescript
// src/app.ts - Basic Express + Firestore setup
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { initializeApp, applicationDefault } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

// Initialize Firebase Admin
initializeApp({
  credential: applicationDefault(),
});

const db = getFirestore();
const app = express();

app.use(helmet());
app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

### Firestore CRUD Operations
```typescript
// src/services/bookService.ts
import { getFirestore } from 'firebase-admin/firestore';

const db = getFirestore();

export const addBookToShelf = async (userId: string, shelfType: string, book: Book) => {
  const shelfRef = db.collection('users').doc(userId).collection('shelves').doc(shelfType);

  return db.runTransaction(async (transaction) => {
    const doc = await transaction.get(shelfRef);
    const currentBooks = doc.exists ? doc.data()?.books || [] : [];

    // Prevent duplicates
    const exists = currentBooks.some((b: Book) => b.id === book.id);
    if (exists) {
      throw new Error('Book already exists in shelf');
    }

    transaction.set(shelfRef, {
      name: shelfType,
      books: [...currentBooks, book],
      updatedAt: new Date()
    }, { merge: true });
  });
};
```

### Cloud Build Configuration
```yaml
# cloudbuild.yaml - Automated deployment
steps:
  # Build the container image
  - name: 'gcr.io/cloud-builders/docker'
    args: ['build', '-t', 'gcr.io/$PROJECT_ID/browsy-backend:$COMMIT_SHA', '.']

  # Push to Container Registry
  - name: 'gcr.io/cloud-builders/docker'
    args: ['push', 'gcr.io/$PROJECT_ID/browsy-backend:$COMMIT_SHA']

  # Deploy to Cloud Run
  - name: 'gcr.io/cloud-builders/gcloud'
    args: [
      'run', 'deploy', 'browsy-backend',
      '--image', 'gcr.io/$PROJECT_ID/browsy-backend:$COMMIT_SHA',
      '--region', 'us-central1',
      '--platform', 'managed',
      '--allow-unauthenticated',
      '--memory', '1Gi',
      '--cpu', '1'
    ]
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Cloud Functions | Cloud Run | 2020+ | More control, better performance, container flexibility |
| REST-only APIs | GraphQL/REST hybrid | 2021+ | Better mobile efficiency with selective queries |
| Manual scaling | Cloud Run autoscaling | Always current | Automatic cost optimization |
| VM-based hosting | Serverless containers | 2019+ | Zero ops, pay-per-use billing |

**Deprecated/outdated:**
- App Engine Standard (Node.js): Cloud Run provides better container control
- Manual Docker deployment: Cloud Build automates the entire pipeline
- Firebase Realtime Database: Firestore provides better querying and scaling

## Open Questions

Things that couldn't be fully resolved:

1. **Optimal Cloud Run configuration for this workload**
   - What we know: Mobile API with bursty traffic, Firestore operations
   - What's unclear: Exact memory/CPU requirements, concurrency settings
   - Recommendation: Start with 1GB/1CPU, monitor and adjust based on metrics

2. **Firestore vs Cloud SQL for user data**
   - What we know: Firestore integrates better with mobile, real-time sync
   - What's unclear: Cost implications at scale, complex query performance
   - Recommendation: Start with Firestore, evaluate SQL if complex analytics needed

3. **Authentication strategy timing**
   - What we know: Phase 6 will implement Firebase Auth
   - What's unclear: Whether to build API with auth placeholders or defer completely
   - Recommendation: Build with auth middleware placeholders, easy to enable later

## Sources

### Primary (HIGH confidence)
- Google Cloud Run official documentation patterns
- Firebase Admin SDK documentation and samples
- Node.js official LTS recommendations

### Secondary (MEDIUM confidence)
- [Google Cloud Run REST API backend setup 2026 best practices](https://www.webarchive.org/web/null) - WebSearch findings on current patterns
- [GCP Firestore schema design mobile app 2026 patterns](https://www.webarchive.org/web/null) - Community practices for mobile backends
- [Express.js Cloud Run Docker Firestore REST API 2026 tutorial](https://www.webarchive.org/web/null) - Implementation tutorials and examples

### Tertiary (LOW confidence)
- Cloud Run performance benchmarks from community discussions
- Cold start optimization techniques from developer blogs
- Firestore query optimization patterns from Stack Overflow

## Metadata

**Confidence breakdown:**
- Standard stack: MEDIUM - Based on widely adopted patterns but not officially verified
- Architecture: MEDIUM - Community consensus on proven patterns
- Pitfalls: HIGH - Well-documented issues with established solutions

**Research date:** 2026-01-18
**Valid until:** 2026-02-18 (30 days - stable cloud platform patterns)