/**
 * Controllers for shelf management API endpoints.
 * Handle HTTP requests and responses for book shelf operations.
 */

import { Request, Response } from 'express';
import { addBookToShelf, removeBookFromShelf, getUserShelves, getShelfBooks as getShelfBooksService } from '../services/bookService';
import { Book, ShelfType } from '../models';

/**
 * POST /api/shelves/:userId/books
 * Add a book to a user's shelf.
 */
export const addBook = async (req: Request, res: Response): Promise<void> => {
  try {
    const { userId } = req.params;
    const { book, shelfType }: { book: Book; shelfType: ShelfType } = req.body;

    await addBookToShelf(userId, shelfType, book);

    res.status(201).json({
      message: 'Book added to shelf successfully',
      data: {
        userId,
        shelfType,
        book: {
          id: book.id,
          title: book.title,
          author: book.author
        }
      }
    });
  } catch (error) {
    console.error('Error adding book to shelf:', error);

    if (error instanceof Error && error.message === 'Book already exists in shelf') {
      res.status(409).json({
        error: 'Duplicate book',
        message: error.message
      });
      return;
    }

    res.status(500).json({
      error: 'Internal server error',
      message: 'Failed to add book to shelf'
    });
  }
};

/**
 * DELETE /api/shelves/:userId/books/:bookId
 * Remove a book from a user's shelf.
 */
export const removeBook = async (req: Request, res: Response): Promise<void> => {
  try {
    const { userId, bookId } = req.params;
    const { shelfType }: { shelfType: ShelfType } = req.body;

    await removeBookFromShelf(userId, shelfType, bookId);

    res.status(200).json({
      message: 'Book removed from shelf successfully',
      data: {
        userId,
        shelfType,
        bookId
      }
    });
  } catch (error) {
    console.error('Error removing book from shelf:', error);

    if (error instanceof Error) {
      if (error.message === 'Shelf does not exist' || error.message === 'Book not found in shelf') {
        res.status(404).json({
          error: 'Not found',
          message: error.message
        });
        return;
      }
    }

    res.status(500).json({
      error: 'Internal server error',
      message: 'Failed to remove book from shelf'
    });
  }
};

/**
 * GET /api/shelves/:userId
 * Get all shelves for a user.
 */
export const getShelves = async (req: Request, res: Response): Promise<void> => {
  try {
    const { userId } = req.params;

    const shelves = await getUserShelves(userId);

    res.status(200).json({
      message: 'User shelves retrieved successfully',
      data: {
        userId,
        shelves
      }
    });
  } catch (error) {
    console.error('Error getting user shelves:', error);

    res.status(500).json({
      error: 'Internal server error',
      message: 'Failed to retrieve user shelves'
    });
  }
};

/**
 * GET /api/shelves/:userId/:shelfType
 * Get books from a specific shelf type for a user.
 */
export const getShelfBooks = async (req: Request, res: Response): Promise<void> => {
  try {
    const { userId, shelfType } = req.params;

    const books = await getShelfBooksService(userId, shelfType as ShelfType);

    res.status(200).json({
      message: 'Shelf books retrieved successfully',
      data: {
        userId,
        shelfType,
        books
      }
    });
  } catch (error) {
    console.error('Error getting shelf books:', error);

    res.status(500).json({
      error: 'Internal server error',
      message: 'Failed to retrieve shelf books'
    });
  }
};