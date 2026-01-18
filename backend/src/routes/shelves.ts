/**
 * Routes for shelf management API endpoints.
 * Defines Express routes with validation middleware and controller handlers.
 */

import { Router } from 'express';
import { addBook, removeBook, getShelves, getShelfBooks } from '../controllers/shelfController';
import {
  validateUserId,
  validateShelfType,
  validateBook,
  validateShelfTypeInBody
} from '../middleware/validation';

const router = Router();

/**
 * POST /api/shelves/:userId/books
 * Add a book to a user's shelf.
 */
router.post(
  '/:userId/books',
  validateUserId,
  validateBook,
  validateShelfTypeInBody,
  addBook
);

/**
 * DELETE /api/shelves/:userId/books/:bookId
 * Remove a book from a user's shelf.
 */
router.delete(
  '/:userId/books/:bookId',
  validateUserId,
  validateShelfTypeInBody,
  removeBook
);

/**
 * GET /api/shelves/:userId
 * Get all shelves for a user.
 */
router.get(
  '/:userId',
  validateUserId,
  getShelves
);

/**
 * GET /api/shelves/:userId/:shelfType
 * Get books from a specific shelf type for a user.
 */
router.get(
  '/:userId/:shelfType',
  validateUserId,
  validateShelfType,
  getShelfBooks
);

export default router;