
import {
  IsOptional,
  IsEnum,
  IsInt,
  IsString,
  IsISO8601,
  Min,
  IsIn,
} from 'class-validator';
import { Type } from 'class-transformer';
import { PaymentMethod, PaymentStatus } from 'utils/types';

export const paymentMethod=["UPI" ,"CARD","NETBANKING","WALLET","CASH"]


export const paymentStatus =["SUCCESS","FAILED", "PENDING"]

export class QueryPaymentsDto {
  @IsOptional()
  @IsIn(paymentStatus)
  status?: PaymentStatus;

  @IsOptional()
  @IsIn(paymentMethod)
  method?: PaymentMethod;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  senderId?: number;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  receiverId?: number;

  @IsOptional()
  startDate?: Date;

  @IsOptional()
  @IsISO8601()
  endDate?: Date;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page: number = 1;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  limit: number = 10;
}
