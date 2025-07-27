import { PaymentObj, RoleType } from "./types";

export interface addUserMessageType{
    userId:number,
    role:RoleType
}
export interface paymentMessageType extends PaymentObj{

}