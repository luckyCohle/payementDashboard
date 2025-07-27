import { Injectable } from '@nestjs/common';
import { UsersService } from 'src/users/users.service';
import * as bcrypt from 'bcrypt'; 
import { sign } from 'jsonwebtoken'; 
import { UserObj } from 'utils/types';


const jwtSecret = "mySecretKey";

@Injectable()
export class AuthService {
  constructor(private userService: UsersService) {}

  async loginUser(userData: UserObj): Promise<string> {
    //hardcoded admin
    if(userData.username == "admin"){
        return "adminIsHere";
    }
    const user = await this.userService.findUser(userData.username);
    if (!user) return "user not found";

    const correctPassword = await bcrypt.compare(userData.password, user.password);
    if (!correctPassword) return "incorrect password";

    const payload = {
      sub: user.id,
      username: user.username,
    };

    const token = sign(payload,jwtSecret); 

    return token;
  }
  async signupUser(userData: UserObj):Promise<string>{
    //check if user already exists
    const alreadyExists = await this.userService.doesUserExist(userData.username);
    if(alreadyExists){
        return "user already exists";
    }
    const newUserData:UserObj={
      ...userData,
      password: await bcrypt.hash(userData.password, 10),
    }
    const newUser = await this.userService.createUser(newUserData);
    if(!newUser){
        return "user signin failed";
    }
      const payload = {
      sub: newUser.id,
      username: newUser.username,
    };

    const token = sign(payload,jwtSecret); 

    return token;
  }
}
