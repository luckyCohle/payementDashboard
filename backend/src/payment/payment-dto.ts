import { PaymentMethod, PaymentStatus } from "@prisma/client";
import { IsDecimal, IsIn, IsInt, IsNotEmpty, IsNumber, IsOptional, IsString } from "class-validator";

export const paymentMethod=["UPI" ,"CARD","NETBANKING","WALLET","CASH"]


export const paymentStatus =["SUCCESS","FAILED", "PENDING"]


export class  PaymentDTO {
    @IsNumber()
    @IsNotEmpty()
    amount:number;

    @IsIn(paymentMethod)
    method:PaymentMethod;

    @IsIn(paymentStatus)
    status:PaymentStatus;

    @IsInt()
    @IsNotEmpty()
    senderId: number

    @IsInt()
    @IsNotEmpty()
    receiverId:number
    @IsOptional()
    createdAt?:Date
}