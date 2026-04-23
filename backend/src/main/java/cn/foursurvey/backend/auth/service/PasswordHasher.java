package cn.foursurvey.backend.auth.service;

import cn.foursurvey.backend.common.exception.ApiException;
import java.security.NoSuchAlgorithmException;
import java.security.spec.InvalidKeySpecException;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;
import org.springframework.stereotype.Component;

@Component
public class PasswordHasher {

    private static final int ITERATIONS = 100_000;
    private static final int KEY_LENGTH = 256;

    public boolean matches(String plainPassword, String saltHex, String expectedHashHex) {
        return hash(plainPassword, saltHex).equalsIgnoreCase(expectedHashHex);
    }

    public String hash(String plainPassword, String saltHex) {
        try {
            PBEKeySpec spec = new PBEKeySpec(
                    plainPassword.toCharArray(),
                    hexToBytes(saltHex),
                    ITERATIONS,
                    KEY_LENGTH);
            SecretKeyFactory factory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256");
            byte[] hashBytes = factory.generateSecret(spec).getEncoded();
            return bytesToHex(hashBytes);
        } catch (NoSuchAlgorithmException | InvalidKeySpecException ex) {
            throw new ApiException(500, "密码组件初始化失败");
        }
    }

    private byte[] hexToBytes(String value) {
        int length = value.length();
        byte[] bytes = new byte[length / 2];
        for (int index = 0; index < length; index += 2) {
            bytes[index / 2] = (byte) Integer.parseInt(value.substring(index, index + 2), 16);
        }
        return bytes;
    }

    private String bytesToHex(byte[] bytes) {
        StringBuilder builder = new StringBuilder(bytes.length * 2);
        for (byte current : bytes) {
            builder.append(String.format("%02x", current));
        }
        return builder.toString();
    }
}
