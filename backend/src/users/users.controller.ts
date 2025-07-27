import { Controller, Get } from '@nestjs/common';
import { UsersService } from './users.service';

@Controller('users')
export class UsersController {
    constructor(private readonly userService : UsersService) {}
    @Get('/admin')
    async getAllAdmin(){
        const adminArray = await this.userService.getAllAdmins();
        return {message : 'Successfully Fetched All Admins',total:adminArray.length, data : {admins : adminArray}}
    }
    @Get('/viewer')
        async getAllViewers() {
            const userArray = await this.userService.getAllViewers()
            return {message: 'Successfully Fetched All Viewers',total:userArray.length, data : {users : userArray}}
        };
    }

