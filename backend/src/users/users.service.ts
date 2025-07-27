import { Injectable } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';
import { UserObj } from 'utils/types';

const prisma = new PrismaClient();

@Injectable()
export class UsersService {
    async  doesUserExist(username:string) :Promise<boolean> {
        const user = await prisma.user.findFirst({ where : { username } })
        if(user){
            return true;
        }
        return false;
    }
    async  findUser(username:string){
        const user =  await prisma.user.findFirst({
            where:{
                username
            }
        })
        return user;
    }
    async createUser(data:UserObj){
        const user = await prisma.user.create({ data });
        return user;
    }
    async getAllAdmins():Promise<UserObj[]>{
        const adminArray = prisma.user.findMany({
            where:{
                role:'ADMIN',
            }
        })
        return adminArray||[];
    }
     async getAllViewers():Promise<UserObj[]>{
        const userArray = prisma.user.findMany({
            where:{
                role:'VIEWER',
            }
        })
        return userArray||[];
    }
}
