/**
 * Firestore service layer for book shelf operations.
 * Implements CRUD operations with transactions for data consistency.
 */

import { getFirestore } from 'firebase-admin/firestore';
import { Book, UserShelf, ShelfType } from '../models';

const db = getFirestore();

/**
 * Add a book to a user's shelf using Firestore transactions.
 * Prevents duplicates and ensures data consistency.
 */
export const addBookToShelf = async (userId: string, shelfType: ShelfType, book: Book): Promise<void> => {
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

/**
 * Remove a book from a user's shelf using Firestore transactions.
 */
export const removeBookFromShelf = async (userId: string, shelfType: ShelfType, bookId: string): Promise<void> => {
  const shelfRef = db.collection('users').doc(userId).collection('shelves').doc(shelfType);

  return db.runTransaction(async (transaction) => {
    const doc = await transaction.get(shelfRef);

    if (!doc.exists) {
      throw new Error('Shelf does not exist');
    }

    const currentBooks = doc.data()?.books || [];
    const filteredBooks = currentBooks.filter((b: Book) => b.id !== bookId);

    if (filteredBooks.length === currentBooks.length) {
      throw new Error('Book not found in shelf');
    }

    transaction.set(shelfRef, {
      name: shelfType,
      books: filteredBooks,
      updatedAt: new Date()
    }, { merge: true });
  });
};

/**
 * Get all shelves for a user.
 * Returns an array of UserShelf objects.
 */
export const getUserShelves = async (userId: string): Promise<UserShelf[]> => {
  try {
    const shelvesRef = db.collection('users').doc(userId).collection('shelves');
    const snapshot = await shelvesRef.get();

    return snapshot.docs.map(doc => {
      const data = doc.data();
      return {
        name: doc.id as ShelfType,
        books: data.books || [],
        updatedAt: data.updatedAt?.toDate() || new Date()
      } as UserShelf;
    });
  } catch (error) {
    console.error('Error getting user shelves:', error);
    throw new Error('Failed to retrieve user shelves');
  }
};

/**
 * Get books from a specific shelf type for a user.
 */
export const getShelfBooks = async (userId: string, shelfType: ShelfType): Promise<Book[]> => {
  try {
    const shelfRef = db.collection('users').doc(userId).collection('shelves').doc(shelfType);
    const doc = await shelfRef.get();

    if (!doc.exists) {
      return [];
    }

    return doc.data()?.books || [];
  } catch (error) {
    console.error('Error getting shelf books:', error);
    throw new Error('Failed to retrieve shelf books');
  }
};