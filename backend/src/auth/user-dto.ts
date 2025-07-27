import { IsIn, IsNotEmpty, IsString } from "class-validator";
import { RoleType } from "utils/types";

 const Roles=["ADMIN","VIEWER"]
 
export class UserDTO {
  @IsString()
  @IsNotEmpty()
  username: string;
  @IsString()
  @IsNotEmpty()
  password: string;
  @IsIn(Roles)
  @IsNotEmpty()
  role: RoleType
}
