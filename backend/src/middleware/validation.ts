/**
 * Request validation middleware for API endpoints.
 * Provides validation for user IDs, shelf types, and book objects.
 */

import { Request, Response, NextFunction } from 'express';
import { Book, ShelfTypes } from '../models';

/**
 * Validates userId parameter format.
 * Ensures userId is a non-empty string.
 */
export const validateUserId = (req: Request, res: Response, next: NextFunction): void => {
  const { userId } = req.params;

  if (!userId || typeof userId !== 'string' || userId.trim().length === 0) {
    res.status(400).json({
      error: 'Invalid user ID',
      message: 'User ID must be a non-empty string'
    });
    return;
  }

  next();
};

/**
 * Validates shelfType parameter.
 * Ensures shelfType is one of the allowed shelf types.
 */
export const validateShelfType = (req: Request, res: Response, next: NextFunction): void => {
  const { shelfType } = req.params;

  const validShelfTypes = Object.values(ShelfTypes);

  if (!shelfType || !validShelfTypes.includes(shelfType as any)) {
    res.status(400).json({
      error: 'Invalid shelf type',
      message: `Shelf type must be one of: ${validShelfTypes.join(', ')}`
    });
    return;
  }

  next();
};

/**
 * Validates book object in request body.
 * Ensures required fields are present and properly formatted.
 */
export const validateBook = (req: Request, res: Response, next: NextFunction): void => {
  const { book } = req.body;

  if (!book || typeof book !== 'object') {
    res.status(400).json({
      error: 'Invalid book data',
      message: 'Request body must contain a valid book object'
    });
    return;
  }

  const { id, title, author } = book as Book;

  // Check required fields
  if (!id || typeof id !== 'string' || id.trim().length === 0) {
    res.status(400).json({
      error: 'Invalid book data',
      message: 'Book ID is required and must be a non-empty string'
    });
    return;
  }

  if (!title || typeof title !== 'string' || title.trim().length === 0) {
    res.status(400).json({
      error: 'Invalid book data',
      message: 'Book title is required and must be a non-empty string'
    });
    return;
  }

  if (!author || typeof author !== 'string' || author.trim().length === 0) {
    res.status(400).json({
      error: 'Invalid book data',
      message: 'Book author is required and must be a non-empty string'
    });
    return;
  }

  // Validate optional fields if present
  if (book.subjects && !Array.isArray(book.subjects)) {
    res.status(400).json({
      error: 'Invalid book data',
      message: 'Book subjects must be an array of strings'
    });
    return;
  }

  next();
};

/**
 * Validates shelfType in request body for add/remove operations.
 */
export const validateShelfTypeInBody = (req: Request, res: Response, next: NextFunction): void => {
  const { shelfType } = req.body;

  const validShelfTypes = Object.values(ShelfTypes);

  if (!shelfType || !validShelfTypes.includes(shelfType as any)) {
    res.status(400).json({
      error: 'Invalid shelf type',
      message: `Shelf type must be one of: ${validShelfTypes.join(', ')}`
    });
    return;
  }

  next();
};