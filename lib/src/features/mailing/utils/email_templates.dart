// lib/src/utils/email_templates.dart
// Templates HTML par défaut pour les emails marketing

class EmailTemplates {
  // Template de base avec le design Pizza Deli'Zza
  static String getDefaultTemplate() {
    return '''
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{subject}}</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            background-color: #f5f5f5;
            padding: 20px;
        }
        .email-container {
            max-width: 600px;
            margin: 0 auto;
            background-color: #ffffff;
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        .header {
            background: linear-gradient(135deg, #E63946 0%, #D62828 100%);
            padding: 40px 20px;
            text-align: center;
        }
        .logo {
            font-size: 32px;
            font-weight: 900;
            color: #ffffff;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.2);
            letter-spacing: 1px;
        }
        .logo-subtitle {
            color: #ffffff;
            font-size: 14px;
            margin-top: 8px;
            opacity: 0.95;
        }
        .banner {
            width: 100%;
            height: auto;
            display: block;
        }
        .content {
            padding: 40px 30px;
        }
        .title {
            font-size: 28px;
            font-weight: bold;
            color: #1D2D3D;
            margin-bottom: 20px;
            line-height: 1.3;
        }
        .body-text {
            font-size: 16px;
            color: #5A6C7D;
            line-height: 1.6;
            margin-bottom: 30px;
        }
        .cta-button {
            display: inline-block;
            background: linear-gradient(135deg, #E63946 0%, #D62828 100%);
            color: #ffffff !important;
            text-decoration: none;
            padding: 16px 40px;
            border-radius: 50px;
            font-weight: bold;
            font-size: 16px;
            text-align: center;
            box-shadow: 0 4px 12px rgba(230, 57, 70, 0.4);
            transition: all 0.3s ease;
        }
        .cta-button:hover {
            box-shadow: 0 6px 16px rgba(230, 57, 70, 0.5);
            transform: translateY(-2px);
        }
        .cta-container {
            text-align: center;
            margin: 30px 0;
        }
        .footer {
            background-color: #f8f9fa;
            padding: 30px;
            text-align: center;
            border-top: 1px solid #e9ecef;
        }
        .footer-text {
            font-size: 12px;
            color: #8B9DAF;
            line-height: 1.6;
            margin-bottom: 12px;
        }
        .footer-link {
            color: #E63946;
            text-decoration: none;
            font-weight: 600;
        }
        .footer-link:hover {
            text-decoration: underline;
        }
        .unsubscribe {
            font-size: 11px;
            color: #8B9DAF;
            margin-top: 16px;
        }
        .unsubscribe a {
            color: #8B9DAF;
            text-decoration: underline;
        }
        .social-icons {
            margin: 20px 0;
        }
        .social-icon {
            display: inline-block;
            margin: 0 8px;
            width: 32px;
            height: 32px;
            background-color: #E63946;
            border-radius: 50%;
            line-height: 32px;
            color: #ffffff;
            text-decoration: none;
        }
        @media only screen and (max-width: 600px) {
            .email-container {
                border-radius: 0;
            }
            .content {
                padding: 30px 20px;
            }
            .title {
                font-size: 24px;
            }
            .body-text {
                font-size: 14px;
            }
            .cta-button {
                padding: 14px 30px;
                font-size: 14px;
            }
        }
    </style>
</head>
<body>
    <div class="email-container">
        <!-- Header avec logo -->
        <div class="header">
            <div class="logo">🍕 Pizza Deli'Zza</div>
            <div class="logo-subtitle">La meilleure pizza, livrée chez vous</div>
        </div>
        
        <!-- Image bannière (optionnelle) -->
        {{#if bannerUrl}}
        <img src="{{bannerUrl}}" alt="Bannière" class="banner">
        {{/if}}
        
        <!-- Contenu principal -->
        <div class="content">
            <h1 class="title">{{subject}}</h1>
            <div class="body-text">
                {{content}}
            </div>
            
            <!-- Bouton CTA -->
            <div class="cta-container">
                <a href="{{ctaUrl}}" class="cta-button">
                    {{ctaText}}
                </a>
            </div>
        </div>
        
        <!-- Footer avec mentions légales -->
        <div class="footer">
            <div class="footer-text">
                <strong>Pizza Deli'Zza</strong><br>
                123 Avenue des Pizzas, 75001 Paris<br>
                Tél: 01 23 45 67 89 | Email: contact@delizza.fr
            </div>
            
            <div class="social-icons">
                <a href="#" class="social-icon">f</a>
                <a href="#" class="social-icon">t</a>
                <a href="#" class="social-icon">i</a>
            </div>
            
            <div class="footer-text">
                Vous recevez cet email car vous êtes inscrit à notre newsletter.<br>
                <a href="{{unsubUrl}}" class="footer-link">Se désinscrire</a>
            </div>
            
            <div class="unsubscribe">
                <a href="{{unsubUrl}}">Cliquez ici pour ne plus recevoir nos emails</a>
            </div>
        </div>
    </div>
</body>
</html>
''';
  }

  // Template promo avec réduction
  static String getPromoTemplate() {
    return '''
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{subject}}</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            background-color: #f5f5f5;
            padding: 20px;
        }
        .email-container {
            max-width: 600px;
            margin: 0 auto;
            background-color: #ffffff;
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        .header {
            background: linear-gradient(135deg, #E63946 0%, #D62828 100%);
            padding: 40px 20px;
            text-align: center;
        }
        .logo {
            font-size: 32px;
            font-weight: 900;
            color: #ffffff;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.2);
        }
        .promo-badge {
            background-color: #FFB703;
            color: #1D2D3D;
            font-size: 48px;
            font-weight: 900;
            padding: 20px;
            margin: 30px 0;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(255, 183, 3, 0.3);
        }
        .content {
            padding: 40px 30px;
            text-align: center;
        }
        .title {
            font-size: 32px;
            font-weight: bold;
            color: #1D2D3D;
            margin-bottom: 20px;
        }
        .body-text {
            font-size: 16px;
            color: #5A6C7D;
            line-height: 1.6;
            margin-bottom: 30px;
        }
        .cta-button {
            display: inline-block;
            background: linear-gradient(135deg, #E63946 0%, #D62828 100%);
            color: #ffffff !important;
            text-decoration: none;
            padding: 18px 50px;
            border-radius: 50px;
            font-weight: bold;
            font-size: 18px;
            box-shadow: 0 6px 16px rgba(230, 57, 70, 0.4);
        }
        .footer {
            background-color: #f8f9fa;
            padding: 30px;
            text-align: center;
            border-top: 1px solid #e9ecef;
        }
        .footer-text {
            font-size: 12px;
            color: #8B9DAF;
            line-height: 1.6;
        }
        .footer-link {
            color: #E63946;
            text-decoration: none;
        }
    </style>
</head>
<body>
    <div class="email-container">
        <div class="header">
            <div class="logo">🍕 Pizza Deli'Zza</div>
        </div>
        
        <div class="content">
            <div class="promo-badge">
                🔥 {{discount}} 🔥
            </div>
            <h1 class="title">{{subject}}</h1>
            <div class="body-text">
                {{content}}
            </div>
            <a href="{{ctaUrl}}" class="cta-button">
                {{ctaText}}
            </a>
        </div>
        
        <div class="footer">
            <div class="footer-text">
                <strong>Pizza Deli'Zza</strong><br>
                <a href="{{unsubUrl}}" class="footer-link">Se désinscrire</a>
            </div>
        </div>
    </div>
</body>
</html>
''';
  }

  // Template nouveauté produit
  static String getNewProductTemplate() {
    return '''
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{subject}}</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            background-color: #f5f5f5;
            padding: 20px;
        }
        .email-container {
            max-width: 600px;
            margin: 0 auto;
            background-color: #ffffff;
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        .header {
            background: linear-gradient(135deg, #E63946 0%, #D62828 100%);
            padding: 40px 20px;
            text-align: center;
        }
        .logo {
            font-size: 32px;
            font-weight: 900;
            color: #ffffff;
        }
        .new-badge {
            background: linear-gradient(135deg, #06A77D 0%, #048a65 100%);
            color: #ffffff;
            display: inline-block;
            padding: 8px 20px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: bold;
            margin: 20px 0;
        }
        .product-image {
            width: 100%;
            max-width: 400px;
            margin: 20px auto;
            display: block;
            border-radius: 12px;
        }
        .content {
            padding: 40px 30px;
            text-align: center;
        }
        .title {
            font-size: 28px;
            font-weight: bold;
            color: #1D2D3D;
            margin-bottom: 20px;
        }
        .body-text {
            font-size: 16px;
            color: #5A6C7D;
            line-height: 1.6;
            margin-bottom: 30px;
        }
        .cta-button {
            display: inline-block;
            background: linear-gradient(135deg, #E63946 0%, #D62828 100%);
            color: #ffffff !important;
            text-decoration: none;
            padding: 16px 40px;
            border-radius: 50px;
            font-weight: bold;
            font-size: 16px;
            box-shadow: 0 4px 12px rgba(230, 57, 70, 0.4);
        }
        .footer {
            background-color: #f8f9fa;
            padding: 30px;
            text-align: center;
            border-top: 1px solid #e9ecef;
        }
        .footer-text {
            font-size: 12px;
            color: #8B9DAF;
            line-height: 1.6;
        }
        .footer-link {
            color: #E63946;
            text-decoration: none;
        }
    </style>
</head>
<body>
    <div class="email-container">
        <div class="header">
            <div class="logo">🍕 Pizza Deli'Zza</div>
            <div class="new-badge">✨ NOUVEAUTÉ</div>
        </div>
        
        <div class="content">
            <img src="{{bannerUrl}}" alt="{{product}}" class="product-image">
            <h1 class="title">{{subject}}</h1>
            <div class="body-text">
                {{content}}
            </div>
            <a href="{{ctaUrl}}" class="cta-button">
                {{ctaText}}
            </a>
        </div>
        
        <div class="footer">
            <div class="footer-text">
                <strong>Pizza Deli'Zza</strong><br>
                <a href="{{unsubUrl}}" class="footer-link">Se désinscrire</a>
            </div>
        </div>
    </div>
</body>
</html>
''';
  }

  // Fonction pour remplacer les variables simples dans un template
  static String compileTemplate(String template, Map<String, String> variables) {
    String compiled = template;
    
    // Remplacer les variables simples {{variable}}
    variables.forEach((key, value) {
      compiled = compiled.replaceAll('{{$key}}', value);
    });
    
    // Gérer les conditionnelles simples {{#if variable}}...{{/if}}
    // Pour une implémentation simple, on peut juste supprimer les blocs if vides
    final ifRegex = RegExp(r'\{\{#if\s+(\w+)\}\}(.*?)\{\{/if\}\}', dotAll: true);
    compiled = compiled.replaceAllMapped(ifRegex, (match) {
      final variable = match.group(1);
      final content = match.group(2);
      // Si la variable existe et n'est pas vide, on garde le contenu
      if (variables.containsKey(variable) && variables[variable]!.isNotEmpty) {
        return content ?? '';
      }
      return '';
    });
    
    return compiled;
  }
}
