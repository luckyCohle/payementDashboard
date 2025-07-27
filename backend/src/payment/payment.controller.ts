import { Body, Controller, Get, Param, Post, Query, ValidationPipe } from '@nestjs/common';
import { PaymentService } from './payment.service';
import { PaymentObj, queryType } from 'utils/types';
import { QueryPaymentsDto } from './query-dto';

@Controller('payment')
export class PaymentController {
     constructor(private readonly paymentService : PaymentService) {}
     @Get()
  async getPayments(@Query(ValidationPipe) query:QueryPaymentsDto) {
    return await this.paymentService.getFilteredPayments(query);
  }

   @Get('stats')
  async getPaymentStats() {
    const stats =await this.paymentService.getPaymentStats();
    return {message:"stats fetched successfully",stats}
  }
    @Get(":id")
    async getPaymentById(@Param('id') id:string){
        const payment = await this.paymentService.getPaymentById(id);
        if(!payment){return {message : "invalid paymentId"}}
        return payment;
    }

  @Post('/')
  async createNewPayment(@Body(ValidationPipe) paymentData:PaymentObj){
    const newPayment =await this.paymentService.createPayment(paymentData);
    if(!newPayment){
        return {error:"transaction failed"}
    }
    return{message :"transation successfull",paymentData:newPayment}

  }
}
