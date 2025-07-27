export interface UserObj {
  username: string;
  password: string;
  role: RoleType
}
export type RoleType = "ADMIN"|"VIEWER"
export type PaymentMethod= 
  "UPI" |"CARD"|"NETBANKING"|"WALLET"|"CASH"


export type PaymentStatus =
  "SUCCESS"|"FAILED"| "PENDING"


export interface  PaymentObj {
    amount:number,
    method:PaymentMethod,
    status:PaymentStatus,
    senderId: number
    receiverId:number
    createdAt?:Date,
}
export interface queryType  {
    method?:PaymentMethod,
    status?:PaymentStatus,
    senderId?: number
    receiverId?:number
     startDate?:Date,
    endDate?:Date,
    page?:number,
    limit?:number,

}