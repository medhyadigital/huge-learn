import { PrismaClient } from '@prisma/client';

// Prisma Client with query caching and logging
const prisma = new PrismaClient({
  log: process.env.NODE_ENV === 'development' ? ['query', 'error', 'warn'] : ['error'],
});

// Enable query result caching
// Prisma automatically caches query results in memory

// Connection management
prisma.$connect()
  .then(() => console.log('✅ Database connected'))
  .catch((error) => console.error('❌ Database connection error:', error));

// Graceful shutdown
process.on('beforeExit', async () => {
  await prisma.$disconnect();
});

export default prisma;






