/**
 * TypeScript models for Browsy backend API.
 * These interfaces match the mobile app's data structures for consistency.
 */

/**
 * Book model matching the mobile app's Book data class.
 * Must be compatible with the Kotlin serializable data structure.
 */
export interface Book {
  id: string;
  title: string;
  author: string;
  coverUrl?: string;
  description?: string;
  publishedDate?: string;
  pageCount?: number;
  isbn?: string;
  subjects: string[];
}

/**
 * User shelf containing books organized by type.
 * Matches mobile app's BookShelf enum values.
 */
export interface UserShelf {
  name: 'TBR' | 'READ' | 'RECOMMEND';
  books: Book[];
  updatedAt: Date;
}

/**
 * Shelf type constants matching mobile app's BookShelf enum.
 */
export const ShelfTypes = {
  TBR: 'TBR' as const,
  READ: 'READ' as const,
  RECOMMEND: 'RECOMMEND' as const
} as const;

export type ShelfType = typeof ShelfTypes[keyof typeof ShelfTypes];

/**
 * Firestore document structure for user data.
 */
export interface UserData {
  email?: string;
  displayName?: string;
  createdAt: Date;
}