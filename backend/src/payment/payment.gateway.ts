import {
  WebSocketGateway,
  WebSocketServer,
  OnGatewayConnection,
  OnGatewayDisconnect,
  SubscribeMessage,
  MessageBody,
  ConnectedSocket,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { addUserMessageType, paymentMessageType } from 'utils/messageType';
import { PaymentService } from './payment.service';

@WebSocketGateway({
  cors: {
    origin: '*',
  },
})
export class PaymentGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

    
  constructor(private readonly paymentService: PaymentService) {} 

  private connectedUsers: Map<Socket,number> = new Map(); // userId -> socket
  private admins: Map<Socket,number> = new Map(); // adminId -> socket

  handleConnection(client: Socket) {
    console.log(`Client connected: ${client.id}`);
    this.server.emit('user', `${client.id} joined`);
  }

  handleDisconnect(client: Socket) {
    console.log(`Client disconnected: ${client.id}`);

    this.connectedUsers.delete(client);
    this.admins.delete(client);

    this.server.emit('user', `${client.id} left`);
  }

  @SubscribeMessage('addUser')
  handleAddMessage(
    @ConnectedSocket() client: Socket,
    @MessageBody() message: addUserMessageType,
  ): void {
    console.log("message=> "+message);
    this.connectedUsers.set( client,message.userId);
    console.log("user array length =>"+this.connectedUsers.size);
    if (message.role === 'ADMIN') {
      this.admins.set(client,message.userId);
      console.log("admin array length=>"+ this.admins.size)
    }
    console.log("sending message")
    this.server.emit('addUser', `[${client.id}] -> ${message.userId} added`);
  }

  @SubscribeMessage('makePayment')
  async handlePayments(
    @ConnectedSocket() client: Socket,
    @MessageBody() message: paymentMessageType,
  ): Promise<void> {
    //add payment in db
    const payment = await this.paymentService.createPayment(message);
    console.log(payment);
    // Notify admins
    this.admins.forEach((userId,socket) => {
      socket.emit('makePayment', message);
    });

    // Notify sender and receiver
   this.connectedUsers.forEach((userId,socket)=>{
    if(userId ==message.senderId || userId == message.receiverId){
        socket.emit('makePayment', message);
    }
   })
  }
}
