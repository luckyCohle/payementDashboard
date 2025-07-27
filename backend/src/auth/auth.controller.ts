import { Body, Controller, Post, ValidationPipe } from '@nestjs/common';
import { AuthService } from './auth.service';
import { UserObj } from 'utils/types';
import { UserDTO } from './user-dto';



@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('login')
  async login(@Body() userData: UserObj): Promise<{ token: string } | { error: string }> {
    const result = await this.authService.loginUser(userData);
    if (result === 'user not found' || result === 'incorrect password') {
      return { error: result };
    }
    return { token: result };
  }

  @Post('signup')
  async signup(@Body(ValidationPipe) userData: UserDTO): Promise<{ token: string } | { error: string }> {
    const result = await this.authService.signupUser(userData);
    if (
      result === 'user already exists' ||
      result === 'user signin failed'
    ) {
      return { error: result };
    }
    return { token: result };
  }
}
