import { Injectable } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';
import { PaymentObj, queryType } from 'utils/types';
const prisma = new PrismaClient();
@Injectable()
export class PaymentService {
    async getPaymentById(id:string):Promise<PaymentObj|null>{
        const payment = await prisma.payment.findUnique({where:{id}});
        if(!payment)return null;
        return payment;
    }

    async createPayment(data:PaymentObj):Promise<any>{
        const payment = prisma.payment.create({
            data
        })
        return payment;
    }
    
   async getFilteredPayments(query:queryType) {
  const {
    page = 1,
    limit = 10,
    status,
    method,
    senderId,
    receiverId,
    startDate,
    endDate,
  } = query;

  const parsedLimit = Number(limit) || 10;
  const parsedPage = Number(page) || 1;
  const skip = (parsedPage - 1) * parsedLimit;

  const filters: any = {};

  if (status) filters.status = status;
  if (method) filters.method = method;
  if (senderId) filters.senderId = Number(senderId);
  if (receiverId) filters.receiverId = Number(receiverId);

  if (startDate || endDate) {
    filters.createdAt = {};
    if (startDate) filters.createdAt.gte = new Date(startDate);
    if (endDate) filters.createdAt.lte = new Date(endDate);
  }

  const [data, total] = await Promise.all([
    prisma.payment.findMany({
      where: filters,
      skip,
      take: parsedLimit,
      orderBy: { createdAt: 'desc' },
    }),
    prisma.payment.count({
      where: filters,
    }),
  ]);

  return {
    total,
    page: parsedPage,
    limit: parsedLimit,
    data,
  };
}


async getPaymentStats() {
  try {
    const [total, failed, sum] = await Promise.all([
      prisma.payment.count(),
      prisma.payment.count({ where: { status: 'FAILED' } }),
      prisma.payment.aggregate({
        _sum: { amount: true },
      }),
    ]);

    const recent = await prisma.payment.groupBy({
      by: ['createdAt'],
      _sum: { amount: true },
      orderBy: { createdAt: 'asc' },
      where: {
        createdAt: {
          gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000), // last 7 days
        },
      },
    });
    return {
      totalTransactions: total,
      failedTransactions: failed,
      totalRevenue: sum._sum.amount || 0,
      recentRevenue: recent.map(r => ({
        date: r.createdAt.toISOString().split('T')[0],
        amount: r._sum.amount || 0,
      })),
    };
  } catch (error) {
    console.error("getPaymentStats error:", error);
    throw new Error("Failed to generate payment stats.");
  }
}



}
