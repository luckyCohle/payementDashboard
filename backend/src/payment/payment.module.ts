import { Module } from '@nestjs/common';
import { PaymentController } from './payment.controller';
import { PaymentService } from './payment.service';

@Module({
  imports:[PaymentModule],
  controllers: [PaymentController],
  providers: [PaymentService]
})
export class PaymentModule {}
