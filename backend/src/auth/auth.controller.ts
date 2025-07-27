import { Body, Controller, Post, HttpException, HttpStatus, ValidationPipe, HttpCode } from '@nestjs/common';
import { AuthService } from './auth.service';
import { UserObj } from 'utils/types';
import { UserDTO } from './user-dto';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('login')
  @HttpCode(HttpStatus.OK)
  async login(@Body() userData: UserObj): Promise<{ token: string }> {
    const result = await this.authService.loginUser(userData);
    console.log("login result "+result)
    if (result === 'user not found' || result === 'incorrect password') {
      throw new HttpException({ error: result }, HttpStatus.UNAUTHORIZED);
    }
    return { token: result };
  }

  @Post('signup')
  @HttpCode(HttpStatus.OK)
  async signup(@Body(ValidationPipe) userData: UserDTO): Promise<{ token: string }> {
    const result = await this.authService.signupUser(userData);
    console.log("signup result "+result)
    if (result === 'user already exists' || result === 'user signin failed') {
      throw new HttpException({ error: result }, HttpStatus.BAD_REQUEST);
    }
    return { token: result };
  }
}
