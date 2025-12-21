import { Router } from 'express';
import { authenticateToken, AuthRequest } from '../middleware/auth';

const router = Router();

// Temporary in-memory notification store (will use database in production)
const notifications: Record<string, any[]> = {};

// GET /api/learning/notifications/me
router.get('/me', authenticateToken, async (req: AuthRequest, res) => {
  try {
    const userId = req.user!.id;
    const { page = '1', limit = '20', unread_only = 'false' } = req.query;
    
    const pageNum = parseInt(page as string);
    const limitNum = Math.min(parseInt(limit as string), 100);
    
    // Get user notifications (mock for now)
    const userNotifications = notifications[userId] || [];
    
    let filteredNotifications = userNotifications;
    if (unread_only === 'true') {
      filteredNotifications = userNotifications.filter(n => !n.is_read);
    }
    
    const startIndex = (pageNum - 1) * limitNum;
    const endIndex = startIndex + limitNum;
    const paginatedNotifications = filteredNotifications.slice(startIndex, endIndex);
    
    const unreadCount = userNotifications.filter(n => !n.is_read).length;
    
    res.json({
      notifications: paginatedNotifications,
      unread_count: unreadCount,
      pagination: {
        current_page: pageNum,
        total_pages: Math.ceil(filteredNotifications.length / limitNum),
        total_items: filteredNotifications.length,
      },
    });
  } catch (error: any) {
    console.error('Error fetching notifications:', error);
    res.status(500).json({ error: 'Failed to fetch notifications' });
  }
});

// PUT /api/learning/notifications/:notificationId/read
router.put('/:notificationId/read', authenticateToken, async (req: AuthRequest, res) => {
  try {
    const { notificationId } = req.params;
    const userId = req.user!.id;
    
    const userNotifications = notifications[userId] || [];
    const notification = userNotifications.find(n => n.notification_id === notificationId);
    
    if (!notification) {
      return res.status(404).json({ error: 'Notification not found' });
    }
    
    notification.is_read = true;
    notification.read_at = new Date().toISOString();
    
    res.json({
      notification_id: notificationId,
      is_read: true,
      read_at: notification.read_at,
    });
  } catch (error: any) {
    console.error('Error marking notification as read:', error);
    res.status(500).json({ error: 'Failed to mark notification as read' });
  }
});

// POST /api/learning/notifications/mark-all-read
router.post('/mark-all-read', authenticateToken, async (req: AuthRequest, res) => {
  try {
    const userId = req.user!.id;
    
    const userNotifications = notifications[userId] || [];
    userNotifications.forEach(n => {
      n.is_read = true;
      n.read_at = new Date().toISOString();
    });
    
    res.json({
      message: 'All notifications marked as read',
      count: userNotifications.length,
    });
  } catch (error: any) {
    console.error('Error marking all as read:', error);
    res.status(500).json({ error: 'Failed to mark all as read' });
  }
});

export default router;



