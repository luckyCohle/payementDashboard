import { Module } from '@nestjs/common';
import { PaymentController } from './payment.controller';
import { PaymentService } from './payment.service';
import { PaymentGateway } from './payment.gateway';

@Module({
  imports:[PaymentModule],
  controllers: [PaymentController],
  providers: [PaymentService,PaymentGateway]
})
export class PaymentModule {}
