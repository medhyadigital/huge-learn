import { Router } from 'express';
import jwt from 'jsonwebtoken';
import bcrypt from 'bcrypt';
import mysql from 'mysql2/promise';
import crypto from 'crypto';

const router = Router();

// Helper function to parse DATABASE_URL
const parseDatabaseUrl = (url: string) => {
  try {
    const parsed = new URL(url);
    return {
      host: parsed.hostname,
      port: parseInt(parsed.port) || 3306,
      user: parsed.username,
      password: decodeURIComponent(parsed.password),
      database: parsed.pathname.slice(1), // Remove leading '/'
    };
  } catch (error) {
    throw new Error('Invalid DATABASE_URL format');
  }
};

// Create connection to HUGE Auth database
const getAuthConnection = async () => {
  const dbUrl = process.env.DATABASE_URL;
  if (!dbUrl) {
    throw new Error('DATABASE_URL not configured');
  }
  
  const config = parseDatabaseUrl(dbUrl);
  return await mysql.createConnection({
    host: config.host,
    port: config.port,
    user: config.user,
    password: config.password,
    database: config.database,
  });
};

// Helper function to check if input is email or phone
const isEmail = (input: string): boolean => {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(input);
};

// Helper function to normalize phone number
const normalizePhone = (phone: string): string => {
  return phone.replace(/\D/g, ''); // Remove non-digits
};

// POST /api/auth/login - Supports email or phone
router.post('/login', async (req, res) => {
  try {
    const { email, phone, password } = req.body;
    
    if (!password) {
      return res.status(400).json({ error: 'Password is required' });
    }
    
    if (!email && !phone) {
      return res.status(400).json({ error: 'Email or phone number is required' });
    }
    
    const connection = await getAuthConnection();
    
    let query: string;
    let params: any[];
    
    // Check if input is email or phone
    if (email) {
      query = 'SELECT id, email, name, password, phone FROM users WHERE email = ?';
      params = [email];
    } else {
      const normalizedPhone = normalizePhone(phone);
      query = 'SELECT id, email, name, password, phone FROM users WHERE phone = ?';
      params = [normalizedPhone];
    }
    
    const [rows]: any = await connection.query(query, params);
    await connection.end();
    
    if (rows.length === 0) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }
    
    const user = rows[0];
    
    // Verify password with bcrypt
    if (!user.password) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }
    
    const isValidPassword = await bcrypt.compare(password, user.password);
    
    if (!isValidPassword) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }
    
    // Generate JWT tokens
    const accessToken = jwt.sign(
      { id: user.id, email: user.email, name: user.name },
      process.env.JWT_SECRET!,
      { expiresIn: '1h' }
    );
    
    const refreshToken = jwt.sign(
      { id: user.id },
      process.env.JWT_SECRET!,
      { expiresIn: '30d' }
    );
    
    res.json({
      access_token: accessToken,
      refresh_token: refreshToken,
      token_type: 'Bearer',
      expires_in: parseInt(process.env.JWT_EXPIRES_IN || '3600'),
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        phone: user.phone || null,
      },
    });
  } catch (error: any) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Internal server error', details: process.env.NODE_ENV === 'development' ? error.message : undefined });
  }
});

// POST /api/auth/register
router.post('/register', async (req, res) => {
  try {
    const { email, phone, password, name } = req.body;
    
    if (!email && !phone) {
      return res.status(400).json({ error: 'Email or phone number is required' });
    }
    
    if (!password || password.length < 6) {
      return res.status(400).json({ error: 'Password must be at least 6 characters' });
    }
    
    if (!name || name.trim().length === 0) {
      return res.status(400).json({ error: 'Name is required' });
    }
    
    const connection = await getAuthConnection();
    
    // Check if user already exists
    let checkQuery: string;
    let checkParams: any[];
    
    if (email) {
      checkQuery = 'SELECT id FROM users WHERE email = ?';
      checkParams = [email];
    } else {
      const normalizedPhone = normalizePhone(phone);
      checkQuery = 'SELECT id FROM users WHERE phone = ?';
      checkParams = [normalizedPhone];
    }
    
    const [existingUsers]: any = await connection.query(checkQuery, checkParams);
    
    if (existingUsers.length > 0) {
      await connection.end();
      return res.status(409).json({ error: 'User already exists with this email or phone' });
    }
    
    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);
    
    // Generate user ID
    const userId = crypto.randomUUID();
    
    // Insert new user
    const normalizedPhone = phone ? normalizePhone(phone) : null;
    const insertQuery = `
      INSERT INTO users (id, email, phone, name, password, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?, NOW(), NOW())
    `;
    
    await connection.query(insertQuery, [userId, email || null, normalizedPhone, name, hashedPassword]);
    await connection.end();
    
    // Generate JWT tokens
    const accessToken = jwt.sign(
      { id: userId, email: email || null, name: name },
      process.env.JWT_SECRET!,
      { expiresIn: '1h' }
    );
    
    const refreshToken = jwt.sign(
      { id: userId },
      process.env.JWT_SECRET!,
      { expiresIn: '30d' }
    );
    
    res.status(201).json({
      access_token: accessToken,
      refresh_token: refreshToken,
      token_type: 'Bearer',
      expires_in: parseInt(process.env.JWT_EXPIRES_IN || '3600'),
      user: {
        id: userId,
        email: email || null,
        phone: normalizedPhone,
        name: name,
      },
    });
  } catch (error: any) {
    console.error('Registration error:', error);
    res.status(500).json({ error: 'Internal server error', details: process.env.NODE_ENV === 'development' ? error.message : undefined });
  }
});

// POST /api/auth/forgot-password
router.post('/forgot-password', async (req, res) => {
  try {
    const { email, phone } = req.body;
    
    if (!email && !phone) {
      return res.status(400).json({ error: 'Email or phone number is required' });
    }
    
    const connection = await getAuthConnection();
    
    let query: string;
    let params: any[];
    
    if (email) {
      query = 'SELECT id, email, name FROM users WHERE email = ?';
      params = [email];
    } else {
      const normalizedPhone = normalizePhone(phone);
      query = 'SELECT id, email, name, phone FROM users WHERE phone = ?';
      params = [normalizedPhone];
    }
    
    const [rows]: any = await connection.query(query, params);
    await connection.end();
    
    // Always return success to prevent user enumeration
    // In production, send reset email/SMS here
    if (rows.length > 0) {
      const user = rows[0];
      // Generate reset token (in production, store this in database with expiry)
      const resetToken = crypto.randomBytes(32).toString('hex');
      
      // TODO: Send reset email/SMS with reset token
      // For now, just log it (remove in production)
      console.log(`Reset token for ${user.email || user.phone}: ${resetToken}`);
      
      res.json({
        message: 'If an account exists with this email/phone, a password reset link has been sent.',
      });
    } else {
      // Still return success to prevent user enumeration
      res.json({
        message: 'If an account exists with this email/phone, a password reset link has been sent.',
      });
    }
  } catch (error: any) {
    console.error('Forgot password error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/auth/reset-password
router.post('/reset-password', async (req, res) => {
  try {
    const { token, new_password } = req.body;
    
    if (!token || !new_password) {
      return res.status(400).json({ error: 'Token and new password are required' });
    }
    
    if (new_password.length < 6) {
      return res.status(400).json({ error: 'Password must be at least 6 characters' });
    }
    
    // TODO: Verify reset token from database
    // For now, this is a placeholder
    // In production, you should:
    // 1. Store reset tokens in database with expiry
    // 2. Verify token is valid and not expired
    // 3. Update password
    // 4. Invalidate token
    
    res.status(501).json({ error: 'Password reset not fully implemented. Please contact support.' });
  } catch (error: any) {
    console.error('Reset password error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/auth/refresh
router.post('/refresh', async (req, res) => {
  try {
    const { refresh_token } = req.body;
    
    if (!refresh_token) {
      return res.status(400).json({ error: 'Refresh token required' });
    }
    
    const decoded = jwt.verify(refresh_token, process.env.JWT_SECRET!) as any;
    
    const connection = await getAuthConnection();
    const [rows]: any = await connection.query(
      'SELECT id, email, name FROM users WHERE id = ?',
      [decoded.id]
    );
    await connection.end();
    
    if (rows.length === 0) {
      return res.status(401).json({ error: 'User not found' });
    }
    
    const user = rows[0];
    
    const accessToken = jwt.sign(
      { id: user.id, email: user.email, name: user.name },
      process.env.JWT_SECRET!,
      { expiresIn: '1h' }
    );
    
    const newRefreshToken = jwt.sign(
      { id: user.id },
      process.env.JWT_SECRET!,
      { expiresIn: '30d' }
    );
    
    res.json({
      access_token: accessToken,
      refresh_token: newRefreshToken,
      token_type: 'Bearer',
      expires_in: parseInt(process.env.JWT_EXPIRES_IN || '3600'),
    });
  } catch (error: any) {
    console.error('Refresh error:', error);
    res.status(401).json({ error: 'Invalid refresh token' });
  }
});

// POST /api/auth/logout
router.post('/logout', async (req, res) => {
  // In production, you might want to blacklist tokens
  res.json({ message: 'Logout successful' });
});

export default router;
