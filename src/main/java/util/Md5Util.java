package util;

import java.security.MessageDigest;

/**
 * MD5 加密工具：密码不明文存储，注册和登录时对密码做 MD5 后再入库/比对
 */
public class Md5Util {
    public static String md5(String text) {
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] digest = md.digest(text.getBytes("UTF-8"));
            StringBuilder sb = new StringBuilder();
            for (byte b : digest) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
