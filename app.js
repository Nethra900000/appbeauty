/* ==========================================================================
   STATE MANAGEMENT
   ========================================================================== */
const state = {
    currentScreenIndex: 1, // 1 to 50
    // AI Variables (customizable in right panel)
    simulatedSkinType: 'Combination (Oily T-Zone)',
    simulatedSkinTone: '#E8C4A0',
    simulatedFaceShape: 'Oval',
    simulatedUserAvatar: 'classic-female',
    simulatedLipstickColor: '#E25858',
    simulatedConfidence: 96,
    
    // UI state
    cameraActive: false,
    cameraStream: null,
    scanPercentage: 0,
    scanInterval: null,
    beforeAfterSliderPos: 50,
    activeSkincareTab: 'am', // 'am' or 'pm'
    makeupFilter: 'All', // 'All', 'Natural', 'Glam', 'Classic'
    
    // Mix and match slots
    mixMatchSlots: {
        top: null,
        bottom: null,
        outer: null
    },

    // AI Chat history
    chatMessages: [
        { sender: 'assistant', text: 'Hi! I am your AI Beauty Genius. Scan your face or ask me anything about skincare, makeup, or styling!' }
    ],

    // Saved looks checklist
    savedLooks: [
        { type: 'Makeup', name: 'Soft Peach Glow', date: '2026-06-10' },
        { type: 'Hairstyle', name: 'Curtain Bangs', date: '2026-06-08' },
        { type: 'Outfit', name: 'Warm Autumn Minimal', date: '2026-06-05' }
    ]
};

// Available outfits for Mix & Match
const clothingItems = {
    tops: [
        { id: 't1', icon: '👚', name: 'Silk Blouse' },
        { id: 't2', icon: '👕', name: 'Linen Tee' },
        { id: 't3', icon: '👔', name: 'Classic Shirt' }
    ],
    bottoms: [
        { id: 'b1', icon: '👖', name: 'Wide Denim' },
        { id: 'b2', icon: 'スカート', name: 'Pencil Skirt', customIcon: '👗' },
        { id: 'b3', icon: '🩳', name: 'Tailored Shorts' }
    ],
    outer: [
        { id: 'o1', icon: '🧥', name: 'Wool Coat' },
        { id: 'o2', icon: '🧥', name: 'Leather Jacket' },
        { id: 'o3', icon: '🧥', name: 'Cardigan' }
    ]
};

// Available hairstyles for preview overlay
const hairstyleOverlays = {
    waves: `<path d="M110,60 C110,20 270,20 270,60 C285,120 275,220 260,250 C250,220 255,140 240,110 C220,90 160,90 140,110 C125,140 130,220 120,250 C105,220 95,120 110,60 Z" fill="rgba(65, 48, 39, 0.95)" stroke="var(--pink-pastel)" stroke-width="1"/>`,
    bob: `<path d="M120,60 C120,20 260,20 260,60 C275,100 270,160 260,175 C250,150 250,110 240,105 C220,85 160,85 140,105 C130,110 130,150 120,175 C110,160 105,100 120,60 Z" fill="rgba(28, 20, 18, 0.98)" stroke="var(--pink-pastel)" stroke-width="1"/>`,
    afro: `<circle cx="190" cy="120" r="80" fill="rgba(34, 25, 20, 0.95)" stroke="var(--pink-pastel)" stroke-width="1.5"/><circle cx="140" cy="110" r="50" fill="rgba(34, 25, 20, 0.95)"/><circle cx="240" cy="110" r="50" fill="rgba(34, 25, 20, 0.95)"/>`,
    pixie: `<path d="M130,65 C130,40 250,40 250,65 C255,80 250,100 240,105 C230,95 230,80 220,80 C190,80 190,80 170,80 C150,80 150,95 140,105 C130,100 125,80 130,65 Z" fill="rgba(80, 50, 40, 0.98)" stroke="var(--pink-pastel)" stroke-width="1"/>`
};

/* ==========================================================================
   SVG AVATARS & VECTOR GRAPHICS
   ========================================================================== */
function getFaceSVG({ tone = '#E8C4A0', hairType = 'waves', showGrid = false, showPoints = false, lipstick = '#E25858', beforeMode = false, afterMode = false }) {
    // Modify colors if showing before / after mode
    let lipColor = afterMode ? lipstick : (beforeMode ? 'rgba(211, 150, 140, 0.7)' : lipstick);
    let skinColor = beforeMode ? '#DFBA99' : tone; // slightly duller skin for before
    let overlayGrid = showGrid ? `
        <!-- Cyber scan grid overlay -->
        <path d="M110,120 L270,120 M110,170 L270,170 M110,210 L270,210 M140,80 L140,240 M190,80 L190,240 M240,80 L240,240" stroke="rgba(120, 224, 160, 0.4)" stroke-width="1" stroke-dasharray="3,3" />
        <ellipse cx="190" cy="160" rx="90" ry="110" fill="none" stroke="var(--glow-emerald)" stroke-width="1.5" stroke-dasharray="5,5" />
    ` : '';
    
    let keyPoints = showPoints ? `
        <!-- Core facial keypoints -->
        <circle cx="190" cy="80" r="4" fill="var(--glow-emerald)" /> <!-- Forehead -->
        <circle cx="120" cy="160" r="4" fill="var(--glow-emerald)" /> <!-- L Cheekbone -->
        <circle cx="260" cy="160" r="4" fill="var(--glow-emerald)" /> <!-- R Cheekbone -->
        <circle cx="190" cy="180" r="4" fill="var(--glow-emerald)" /> <!-- Nose Tip -->
        <circle cx="190" cy="225" r="4" fill="var(--glow-emerald)" /> <!-- Lips -->
        <circle cx="155" cy="240" r="4" fill="var(--glow-emerald)" /> <!-- L Jaw -->
        <circle cx="225" cy="240" r="4" fill="var(--glow-emerald)" /> <!-- R Jaw -->
        <circle cx="190" cy="265" r="4" fill="var(--glow-emerald)" /> <!-- Chin -->
        <!-- Connection lines -->
        <path d="M190,80 L190,180 L190,225 L190,265 M120,160 L190,180 L260,160 M155,240 L190,265 L225,240" stroke="rgba(120, 224, 160, 0.5)" stroke-width="1" />
    ` : '';

    return `
    <svg viewBox="0 0 380 340" class="face-illustration-svg" style="width: 100%; height: 100%;">
        <defs>
            <!-- Shadow effects -->
            <filter id="shadow" x="-10%" y="-10%" width="120%" height="120%">
                <feDropShadow dx="0" dy="4" stdDeviation="4" flood-opacity="0.15"/>
            </filter>
            <linearGradient id="skinGrad" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0%" stop-color="${skinColor}"/>
                <stop offset="100%" stop-color="#CAAA8A"/>
            </linearGradient>
        </defs>

        <!-- Face Shape BG (Wireframe ellipse) -->
        <ellipse cx="190" cy="165" rx="80" ry="105" fill="url(#skinGrad)" filter="url(#shadow)" />

        <!-- Eyes -->
        <ellipse cx="155" cy="145" rx="12" ry="7" fill="#fff" />
        <circle cx="155" cy="145" r="6" fill="#4A3728" />
        <circle cx="153" cy="143" r="2" fill="#fff" /> <!-- eye shine -->
        <path d="M140,140 C145,135 165,135 170,140" fill="none" stroke="#2D2016" stroke-width="1.5" />

        <ellipse cx="225" cy="145" rx="12" ry="7" fill="#fff" />
        <circle cx="225" cy="145" r="6" fill="#4A3728" />
        <circle cx="223" cy="143" r="2" fill="#fff" /> <!-- eye shine -->
        <path d="M210,140 C215,135 235,135 240,140" fill="none" stroke="#2D2016" stroke-width="1.5" />

        <!-- Eyebrows -->
        <path d="M138,132 C145,124 165,124 172,130" fill="none" stroke="#2D2016" stroke-width="3" stroke-linecap="round" />
        <path d="M208,130 C215,124 235,124 242,132" fill="none" stroke="#2D2016" stroke-width="3" stroke-linecap="round" />

        <!-- Nose -->
        <path d="M190,135 L190,185 C190,192 182,192 190,192 C198,192 190,192 190,185" fill="none" stroke="rgba(0,0,0,0.15)" stroke-width="2.5" stroke-linecap="round" />

        <!-- Cheeks / Blush -->
        <ellipse cx="140" cy="180" rx="18" ry="12" fill="${afterMode ? 'rgba(235, 114, 153, 0.45)' : 'rgba(221, 183, 171, 0.25)'}" filter="blur(2px)" />
        <ellipse cx="240" cy="180" rx="18" ry="12" fill="${afterMode ? 'rgba(235, 114, 153, 0.45)' : 'rgba(221, 183, 171, 0.25)'}" filter="blur(2px)" />

        <!-- Lips -->
        <!-- Upper Lip -->
        <path d="M165,215 Q190,205 215,215 Q190,223 165,215 Z" fill="${lipColor}" />
        <!-- Lower Lip -->
        <path d="M165,215 Q190,232 215,215 Q190,223 165,215 Z" fill="${lipColor}" opacity="0.9" />
        <!-- Lip center line -->
        <path d="M165,215 Q190,218 215,215" fill="none" stroke="rgba(0,0,0,0.15)" stroke-width="1" />

        <!-- Hair overlay (under grid for look) -->
        <g id="hair-group">
            ${hairType ? (hairstyleOverlays[hairType] || '') : ''}
        </g>

        ${overlayGrid}
        ${keyPoints}
    </svg>
    `;
}

// Simple Male Portrait Fallback
function getMaleFaceSVG({ tone = '#D1A378', hairType = 'pixie', showGrid = false, showPoints = false }) {
    let overlayGrid = showGrid ? `
        <ellipse cx="190" cy="160" rx="85" ry="115" fill="none" stroke="var(--glow-emerald)" stroke-width="1.5" stroke-dasharray="5,5" />
    ` : '';
    return `
    <svg viewBox="0 0 380 340" style="width: 100%; height: 100%;">
        <ellipse cx="190" cy="165" rx="76" ry="108" fill="${tone}" />
        <!-- Eyes -->
        <circle cx="158" cy="150" r="5" fill="#222" />
        <circle cx="222" cy="150" r="5" fill="#222" />
        <!-- Eyebrows -->
        <path d="M142,140 Q158,134 172,140" fill="none" stroke="#222" stroke-width="3.5" />
        <path d="M208,140 Q222,134 238,140" fill="none" stroke="#222" stroke-width="3.5" />
        <!-- Nose -->
        <path d="M190,140 L190,190 Q190,195 185,195" fill="none" stroke="rgba(0,0,0,0.15)" stroke-width="3" />
        <!-- Lips -->
        <path d="M168,220 Q190,215 212,220 Q190,228 168,220" fill="#CA7878" />
        <!-- Hair -->
        <path d="M120,70 Q190,20 260,70 Q270,120 260,110 Q190,80 120,110 Q110,120 120,70" fill="#222" />
        ${overlayGrid}
    </svg>
    `;
}

/* ==========================================================================
   RENDER ENGINE FOR 50 SCREENS
   ========================================================================== */
function getScreenHTML(index) {
    const isDark = document.body.classList.contains('dark-theme-active') || index === 1 || index === 12 || index === 14;
    const bodyClass = isDark ? 'dark-theme-active' : '';
    
    // Core Layout wraps
    const wrapStart = `<div class="screen-wrapper ${bodyClass}">`;
    const wrapEnd = `</div>`;

    // Standard Nav Header
    const appHeader = (title) => `
        <div class="app-header">
            <button class="app-back-btn" onclick="goToScreen(${Math.max(1, index - 1)})">←</button>
            <h2>${title}</h2>
            <div style="width: 24px;"></div>
        </div>
    `;

    // Simulated Avatar/Visual
    const currentAvatar = () => {
        const tone = state.simulatedSkinTone;
        const hair = (index >= 37 && index <= 40) ? 'waves' : 'bob';
        const showGrid = (index === 12 || index === 13 || index === 14);
        const showPoints = (index === 22 || index === 14);
        const lipstick = state.simulatedLipstickColor;
        
        if (state.simulatedUserAvatar === 'classic-male') {
            return getMaleFaceSVG({ tone, showGrid, showPoints });
        }
        
        // Before/After screen custom override
        const beforeMode = (index === 25);
        const afterMode = false; // Slider does this
        return getFaceSVG({ tone, hairType: hair, showGrid, showPoints, lipstick, beforeMode, afterMode });
    };

    // Screens list templates switch
    switch(index) {
        
        // I. AUTHENTICATION
        case 1: // Splash Screen
            return wrapStart + `
                <div class="splash-container">
                    <div class="splash-logo-circle">
                        <span class="splash-icon">✦</span>
                    </div>
                    <div>
                        <h1 class="splash-title brand-font">AI Beauty Genius</h1>
                        <p class="splash-subtitle">Intelligent Styling</p>
                    </div>
                    <div class="splash-loader">
                        <div class="splash-loader-bar"></div>
                    </div>
                    <button class="app-btn app-btn-primary" style="margin-top:20px;" onclick="goToScreen(2)">Get Started</button>
                </div>
            ` + wrapEnd;

        case 2: // Onboarding Screen 1 (Intro to scan)
            return wrapStart + `
                <div class="onboard-content">
                    <div class="onboard-illustration">
                        <div class="scanner-visual-mock">
                            ${getFaceSVG({ tone: '#E5C19E', hairType: 'waves', showGrid: true })}
                            <div class="scanner-line"></div>
                        </div>
                    </div>
                    <div class="onboard-text">
                        <h3>Discover Your Face</h3>
                        <p>Analyze skin texture, shape alignment and feature layout using our hyper-precise AI model mapping system.</p>
                    </div>
                    <div class="onboard-footer">
                        <div class="page-dots">
                            <span class="dot active"></span>
                            <span class="dot"></span>
                        </div>
                        <button class="app-btn app-btn-primary" onclick="goToScreen(3)">Continue</button>
                    </div>
                </div>
            ` + wrapEnd;

        case 3: // Onboarding Screen 2 (Features overview)
            return wrapStart + `
                <div class="onboard-content">
                    <div class="onboard-text" style="margin-top: 10px;">
                        <h3>Personalized Styling</h3>
                        <p>Receive tailor-made recommendations on cosmetic matches, skincare regimes, hair options, and seasonal outfits.</p>
                    </div>
                    <div class="onboard-features-list">
                        <div class="feature-item">
                            <div class="feature-icon-wrapper">💄</div>
                            <div class="feature-desc">
                                <h4>Makeup Matching</h4>
                                <p>Exact matches for lipstick, foundation & shadows.</p>
                            </div>
                        </div>
                        <div class="feature-item">
                            <div class="feature-icon-wrapper">🧴</div>
                            <div class="feature-desc">
                                <h4>Skincare Science</h4>
                                <p>Ingredent targets matching your oily/dry zones.</p>
                            </div>
                        </div>
                        <div class="feature-item">
                            <div class="feature-icon-wrapper">👗</div>
                            <div class="feature-desc">
                                <h4>Outfit Color Wheel</h4>
                                <p>Personal seasonal color palettes tailored for you.</p>
                            </div>
                        </div>
                    </div>
                    <div class="onboard-footer">
                        <div class="page-dots">
                            <span class="dot"></span>
                            <span class="dot active"></span>
                        </div>
                        <button class="app-btn app-btn-primary" onclick="goToScreen(4)">Go to Login</button>
                    </div>
                </div>
            ` + wrapEnd;

        case 4: // Login Screen
            return wrapStart + `
                <div class="auth-logo">
                    <h2>Welcome Back</h2>
                    <p>AI BEAUTY GENIUS</p>
                </div>
                <div class="auth-form">
                    <div class="input-field">
                        <label>Email Address</label>
                        <input type="email" placeholder="name@beautygenius.ai" value="user@example.com" />
                    </div>
                    <div class="input-field">
                        <label>Password</label>
                        <input type="password" placeholder="••••••••" value="password123" />
                    </div>
                    <div class="forgot-pass">Forgot Password?</div>
                    <button class="app-btn app-btn-primary" onclick="goToScreen(6)" style="margin-top:10px;">Sign In</button>
                </div>
                <div class="social-login">
                    <p>Or Connect With</p>
                    <div class="social-icons-row">
                        <button class="social-icon-btn">G</button>
                        <button class="social-icon-btn">f</button>
                        <button class="social-icon-btn"></button>
                    </div>
                </div>
                <div class="auth-bottom-link">
                    Don't have an account? <span onclick="goToScreen(5)">Sign Up</span>
                </div>
            ` + wrapEnd;

        case 5: // Signup Screen
            return wrapStart + `
                <div class="auth-logo">
                    <h2>Create Account</h2>
                    <p>START YOUR BEAUTY JOURNEY</p>
                </div>
                <div class="auth-form">
                    <div class="input-field">
                        <label>Full Name</label>
                        <input type="text" placeholder="Gigi Hadid" />
                    </div>
                    <div class="input-field">
                        <label>Email Address</label>
                        <input type="email" placeholder="name@domain.com" />
                    </div>
                    <div class="input-field">
                        <label>Password</label>
                        <input type="password" placeholder="Min. 8 characters" />
                    </div>
                    <div style="display:flex; gap:8px; align-items:center; font-size:11px; margin-top:4px;">
                        <input type="checkbox" id="terms-agree" checked />
                        <label for="terms-agree" style="text-transform:none;">I agree to the Terms & Privacy Policy</label>
                    </div>
                    <button class="app-btn app-btn-primary" onclick="goToScreen(6)" style="margin-top:10px;">Create Profile</button>
                </div>
                <div class="auth-bottom-link">
                    Already registered? <span onclick="goToScreen(4)">Log In</span>
                </div>
            ` + wrapEnd;

        // II. HOME & NAVIGATION
        case 6: // Home Dashboard
            return wrapStart + `
                <div class="home-welcome">
                    <div class="welcome-user">
                        <div class="user-avatar-mini">${currentAvatar()}</div>
                        <div class="welcome-user-text">
                            <h4>Hello, Gorgeous</h4>
                            <p>Ready for your daily analysis?</p>
                        </div>
                    </div>
                    <button class="notification-bell-btn" onclick="goToScreen(8)">🔔</button>
                </div>

                <div class="scan-cta-card">
                    <h3>AI Face Scanner</h3>
                    <p>Map your pores, tone, and jaw alignment in 10 seconds.</p>
                    <div class="scan-cta-circle" onclick="goToScreen(11)">✦</div>
                </div>

                <div class="quick-preview-box">
                    <h4>Last Analysis Results</h4>
                    <div class="quick-preview-grid">
                        <div class="preview-stat">
                            <span>Skin Type</span>
                            <strong>${state.simulatedSkinType.split(' ')[0]}</strong>
                        </div>
                        <div class="preview-stat">
                            <span>Face Shape</span>
                            <strong>${state.simulatedFaceShape}</strong>
                        </div>
                        <div class="preview-stat">
                            <span>Tone Hue</span>
                            <div style="display:inline-block; width:10px; height:10px; border-radius:50%; background:${state.simulatedSkinTone}; vertical-align:middle; margin-right:4px;"></div>
                            <strong>Undertone</strong>
                        </div>
                        <div class="preview-stat">
                            <span>AI confidence</span>
                            <strong>${state.simulatedConfidence}%</strong>
                        </div>
                    </div>
                </div>

                <div class="daily-tip-card">
                    <div style="font-size:24px;">💡</div>
                    <div>
                        <strong style="font-size:12px; display:block;">Daily Expert Tip</strong>
                        <p>Apply moisturizer on damp skin to seal hydration layers deeper into the dermis.</p>
                    </div>
                </div>
                ${getBottomNavHTML(6)}
            ` + wrapEnd;

        case 7: // Bottom Navigation UI State
            return wrapStart + `
                ${appHeader('Navigation Interface')}
                <div class="app-card" style="text-align:center;">
                    <p style="font-size:12px; margin-bottom:12px;">This screen showcases the highlight states, grid layouts, and click behaviors of the application navigation bar.</p>
                    <div class="app-btn-outline" style="padding:10px; margin-bottom:8px;">Home Selected (Screen 6)</div>
                    <div class="app-btn-outline" style="padding:10px; margin-bottom:8px;">Camera Selected (Screen 12)</div>
                    <div class="app-btn-outline" style="padding:10px; margin-bottom:8px;">Saved Archive (Screen 47)</div>
                </div>
                ${getBottomNavHTML(7)}
            ` + wrapEnd;

        case 8: // Notifications Screen
            return wrapStart + `
                ${appHeader('Notifications')}
                <div class="notif-list" style="margin-top: 10px;">
                    <div class="notif-item unread">
                        <div class="notif-icon">🧬</div>
                        <div class="notif-details">
                            <h5>New Skin Analysis Ready</h5>
                            <p>We found a 4% moisture decrease on your forehead zone. Check recommendations.</p>
                            <span>2 mins ago</span>
                        </div>
                    </div>
                    <div class="notif-item unread">
                        <div class="notif-icon">💄</div>
                        <div class="notif-details">
                            <h5>Summer Coral Trend Lipstick</h5>
                            <p>3 coral options perfectly match your warm golden undertone profile.</p>
                            <span>1 hour ago</span>
                        </div>
                    </div>
                    <div class="notif-item">
                        <div class="notif-icon">👑</div>
                        <div class="notif-details">
                            <h5>Subscription Confirmed</h5>
                            <p>Welcome to VIP! You unlocked 3D live filters & fashion mix canvas.</p>
                            <span>Yesterday</span>
                        </div>
                    </div>
                </div>
                ${getBottomNavHTML(8)}
            ` + wrapEnd;

        case 9: // Search Screen
            return wrapStart + `
                <div class="search-filter-box" style="margin-top: 20px;">
                    <input type="text" placeholder="Search looks, styles, ingredients..." value="Dewy Glow" />
                    <span class="search-icon">🔍</span>
                </div>
                <div style="margin-top: 10px;">
                    <h4 style="font-size:12px; font-weight:600; margin-bottom:12px; text-transform:uppercase;">Popular Searches</h4>
                    <div style="display:flex; flex-wrap:wrap; gap:8px;">
                        <span class="app-card" style="padding:6px 12px; margin:0; font-size:11px; border-radius:12px; cursor:pointer;">Glass Skin Care</span>
                        <span class="app-card" style="padding:6px 12px; margin:0; font-size:11px; border-radius:12px; cursor:pointer;">Cat-Eye Wing</span>
                        <span class="app-card" style="padding:6px 12px; margin:0; font-size:11px; border-radius:12px; cursor:pointer;">Layered Bob</span>
                        <span class="app-card" style="padding:6px 12px; margin:0; font-size:11px; border-radius:12px; cursor:pointer;">Warm Palette</span>
                    </div>
                    
                    <h4 style="font-size:12px; font-weight:600; margin:20px 0 12px; text-transform:uppercase;">Recent Trending Looks</h4>
                    <div style="display:grid; grid-template-columns:1fr 1fr; gap:12px;">
                        <div class="app-card" style="padding:8px;">
                            <div style="height:80px; background:#e8e8ed; border-radius:10px; display:flex; justify-content:center; align-items:center; font-size:20px;">🍓</div>
                            <strong style="font-size:11px; display:block; margin-top:6px;">Strawberry Makeup</strong>
                        </div>
                        <div class="app-card" style="padding:8px;">
                            <div style="height:80px; background:#e8e8ed; border-radius:10px; display:flex; justify-content:center; align-items:center; font-size:20px;">☕</div>
                            <strong style="font-size:11px; display:block; margin-top:6px;">Espresso Glam</strong>
                        </div>
                    </div>
                </div>
                ${getBottomNavHTML(9)}
            ` + wrapEnd;

        case 10: // Voice Assistant / AI Chat
            return wrapStart + `
                ${appHeader('Beauty Assistant AI')}
                <div class="chat-container">
                    <div class="chat-history" id="chat-history-viewport">
                        ${state.chatMessages.map(msg => `
                            <div class="chat-bubble ${msg.sender}">
                                ${msg.text}
                            </div>
                        `).join('')}
                    </div>
                    <div class="chat-input-row">
                        <input type="text" id="chat-message-input" placeholder="Ask about skin tone, matching colors..." onkeydown="handleChatSubmit(event)" />
                        <button class="chat-send-btn" onclick="submitChatMessage()">➔</button>
                    </div>
                </div>
                ${getBottomNavHTML(10)}
            ` + wrapEnd;

        // III. FACE SCANNING FLOW
        case 11: // Camera Permission Screen
            return wrapStart + `
                <div class="permission-box">
                    <div class="permission-graphic">📷</div>
                    <div>
                        <h3>Camera Permission</h3>
                        <p>We require camera viewport permissions to scan structural keypoints, color metrics, and skin light bounces.</p>
                    </div>
                    <div style="width: 100%; display:flex; flex-direction:column; gap:10px;">
                        <button class="app-btn app-btn-primary" onclick="initiateCameraScan()">Allow Access</button>
                        <button class="app-btn app-btn-secondary" onclick="goToScreen(15)">Upload Image Instead</button>
                    </div>
                </div>
            ` + wrapEnd;

        case 12: // Face Scan Screen
            return wrapStart + `
                <div class="scanner-viewport">
                    <div class="scan-laser-line"></div>
                    <div id="camera-stream-container" style="width:100%; height:100%; display:flex; align-items:center; justify-content:center; background:#1C1C24;">
                        ${currentAvatar()}
                    </div>
                    <div class="scanner-hud">
                        <strong>Futuristic Scan Active</strong><br/>Keep face center and stable.
                    </div>
                    <!-- Camera triggers inside mockup -->
                    <button class="app-btn app-btn-primary" style="position:absolute; bottom:80px; width:80%; left:10%; z-index:9;" onclick="goToScreen(13)">Align Profile</button>
                </div>
            ` + wrapEnd;

        case 13: // Face Alignment Guide Screen
            return wrapStart + `
                <div class="scanner-viewport">
                    <div id="camera-stream-container-2" style="width:100%; height:100%; display:flex; align-items:center; justify-content:center; background:#1C1C24;">
                        ${currentAvatar()}
                    </div>
                    <!-- Overlay Oval Guide -->
                    <div style="position:absolute; top:50%; left:50%; transform:translate(-50%,-50%); width:180px; height:240px; border:2.5px solid var(--glow-ai); border-radius:50%; z-index:8; box-shadow:0 0 0 9999px rgba(0,0,0,0.5);"></div>
                    <div style="position:absolute; top:20%; left:50%; transform:translateX(-50%); text-align:center; color:#fff; font-size:12px; z-index:9; font-weight:600; text-shadow:0 2px 4px #000;">
                        ALIGN YOUR FACE WITHIN THE OVAL
                    </div>
                    <button class="app-btn app-btn-primary" style="position:absolute; bottom:30px; width:80%; left:10%; z-index:9;" onclick="triggerScanProgress()">Analyze Face Now</button>
                </div>
            ` + wrapEnd;

        case 14: // Scanning Animation Screen
            return wrapStart + `
                <div class="scanner-viewport">
                    <div class="scan-laser-line" style="animation-duration: 1.5s;"></div>
                    <div style="width:100%; height:100%; display:flex; align-items:center; justify-content:center; background:#0B0B0E;">
                        ${getFaceSVG({ tone: state.simulatedSkinTone, hairType: 'waves', showGrid: true, showPoints: true })}
                    </div>
                    <div style="position:absolute; top:40%; width:100%; text-align:center; color:var(--glow-emerald); font-weight:700; font-size:13px; z-index:10; text-shadow:0 0 10px rgba(0,255,0,0.4);">
                        AI MAPPING NODES ACTIVE...
                    </div>
                    <div class="scanner-hud">
                        Scanning forehead, cheeks, jaw contours...
                    </div>
                </div>
            ` + wrapEnd;

        case 15: // Upload Image Screen
            return wrapStart + `
                ${appHeader('Upload Portrait')}
                <div class="app-card" style="border: 2px dashed var(--pink-pastel); height: 260px; display:flex; flex-direction:column; justify-content:center; align-items:center; text-align:center; cursor:pointer;" onclick="goToScreen(16)">
                    <span style="font-size:48px; margin-bottom:12px;">📁</span>
                    <strong style="font-size:14px;">Drag & Drop Photo</strong>
                    <p style="font-size:11px; opacity:0.6; margin-top:6px;">Supported: JPG, PNG. Make sure background is bright and neutral.</p>
                </div>
                <button class="app-btn app-btn-secondary" style="margin-top:20px;" onclick="goToScreen(11)">Use Camera Instead</button>
            ` + wrapEnd;

        case 16: // Retake / Confirm Image Screen
            return wrapStart + `
                ${appHeader('Confirm Portrait')}
                <div class="app-card" style="height: 280px; padding:0; overflow:hidden; display:flex; justify-content:center; align-items:center; background:#ccc;">
                    ${currentAvatar()}
                </div>
                <div style="display:grid; grid-template-columns:1fr 1fr; gap:12px; margin-top:20px;">
                    <button class="app-btn app-btn-secondary" onclick="goToScreen(15)">Retake</button>
                    <button class="app-btn app-btn-primary" onclick="triggerScanProgress()">Confirm</button>
                </div>
            ` + wrapEnd;

        case 17: // Scan Progress Screen
            return wrapStart + `
                <div class="progress-container">
                    <div class="circular-progress-wrap">
                        <svg class="circular-progress-svg">
                            <circle class="circular-progress-bg" cx="80" cy="80" r="70"></circle>
                            <circle class="circular-progress-fill" id="progress-circle-meter" cx="80" cy="80" r="70" style="stroke-dashoffset: 440;"></circle>
                        </svg>
                        <div class="progress-text-counter" id="progress-val-text">0%</div>
                    </div>
                    <div class="progress-status-messages">
                        <h3 id="progress-status-title">Calibrating RGB Light</h3>
                        <p id="progress-status-subtitle">Evaluating light bounces on forehead...</p>
                    </div>
                </div>
            ` + wrapEnd;

        case 18: // Scan Success Screen
            return wrapStart + `
                <div class="progress-container" style="gap:20px;">
                    <div style="width:90px; height:90px; border-radius:50%; background:rgba(120, 224, 160, 0.1); border:2px solid var(--glow-emerald); display:flex; justify-content:center; align-items:center; font-size:40px; color:var(--glow-emerald); box-shadow:0 0 20px rgba(120, 224, 160, 0.2);">
                        ✓
                    </div>
                    <div style="text-align:center;">
                        <h2 style="font-family:'DM Serif Display', serif; font-size:26px;">Analysis Complete</h2>
                        <p style="font-size:12px; opacity:0.7; margin-top:6px;">All facial metrics mapped successfully.</p>
                    </div>
                    <button class="app-btn app-btn-primary" style="margin-top:20px; width:90%;" onclick="goToScreen(19)">View Skin Report</button>
                </div>
            ` + wrapEnd;

        // IV. AI ANALYSIS RESULTS
        case 19: // Skin Type Result
            return wrapStart + `
                ${appHeader('Skin Type Result')}
                <div class="app-card" style="text-align:center;">
                    <span style="font-size:10px; font-weight:700; text-transform:uppercase; color:var(--gold-accent); letter-spacing:0.05em;">AI DETECTION</span>
                    <h3 style="font-size:22px; margin-top:4px;">${state.simulatedSkinType}</h3>
                    <p style="font-size:12px; opacity:0.8; margin-top:8px;">Oily sebum concentrate detected in T-zone areas. Moderate epidermal dry scales detected on cheek sections.</p>
                </div>

                <div class="app-card">
                    <h4 style="font-size:12px; font-weight:600; text-transform:uppercase; margin-bottom:12px;">Sebum Breakdown</h4>
                    <div class="skin-score-bar-row">
                        <div class="score-bar-label"><span>Forehead Sebum</span><strong>74% (High)</strong></div>
                        <div class="score-bar-track"><div class="score-bar-fill" style="width: 74%;"></div></div>
                    </div>
                    <div class="skin-score-bar-row">
                        <div class="score-bar-label"><span>Cheek Moisture</span><strong>42% (Dry)</strong></div>
                        <div class="score-bar-track"><div class="score-bar-fill" style="width: 42%;"></div></div>
                    </div>
                    <div class="skin-score-bar-row">
                        <div class="score-bar-label"><span>Elasticity</span><strong>89% (Optimal)</strong></div>
                        <div class="score-bar-track"><div class="score-bar-fill" style="width: 89%;"></div></div>
                    </div>
                </div>
                <button class="app-btn app-btn-primary" onclick="goToScreen(20)">Next: Skin Tone</button>
            ` + wrapEnd;

        case 20: // Skin Tone Detection Screen
            return wrapStart + `
                ${appHeader('Skin Tone')}
                <div class="app-card" style="text-align:center;">
                    <span style="font-size:10px; color:var(--gold-accent); font-weight:700;">RGB MATCHING</span>
                    <h3 style="font-size:22px; margin-top:4px;">Warm Honey</h3>
                    <p style="font-size:12px; opacity:0.8; margin-top:6px;">Your undertone matches a warm, golden-brown structure.</p>
                    <div class="tone-swatch-box" style="background:${state.simulatedSkinTone};"></div>
                </div>

                <div class="app-card">
                    <h4 style="font-size:12px; font-weight:600; text-transform:uppercase; margin-bottom:12px;">Identified Undertones</h4>
                    <div style="display:flex; justify-content:space-between; align-items:center; border-bottom:1px solid var(--beauty-border-light); padding-bottom:8px; font-size:12px;">
                        <span>Primary undertone</span><strong>Warm/Golden</strong>
                    </div>
                    <div style="display:flex; justify-content:space-between; align-items:center; padding-top:8px; font-size:12px;">
                        <span>Suggested Colors</span><strong style="color:var(--gold-accent);">Beige, Peach, Coral</strong>
                    </div>
                </div>
                <button class="app-btn app-btn-primary" onclick="goToScreen(21)">Next: Face Shape</button>
            ` + wrapEnd;

        case 21: // Face Shape Detection Screen
            return wrapStart + `
                ${appHeader('Face Shape')}
                <div class="face-shape-outline-box">
                    <div class="face-wireframe-svg">
                        ${currentAvatar()}
                    </div>
                </div>
                <div class="app-card" style="text-align:center; margin-top:-10px;">
                    <span style="font-size:10px; color:var(--gold-accent); font-weight:700;">CONTOUR ANALYSIS</span>
                    <h3 style="font-size:22px; margin-top:4px;">${state.simulatedFaceShape} Face</h3>
                    <p style="font-size:12px; opacity:0.8; margin-top:6px;">Balanced width-to-height ratio with gently rounded jaw margins.</p>
                </div>
                <button class="app-btn app-btn-primary" onclick="goToScreen(22)">Next: Feature Break</button>
            ` + wrapEnd;

        case 22: // Facial Features Breakdown Screen
            return wrapStart + `
                ${appHeader('Features Breakdown')}
                <div style="height: 180px; display:flex; justify-content:center; align-items:center; margin-bottom:16px;">
                    ${getFaceSVG({ tone: state.simulatedSkinTone, hairType: 'waves', showPoints: true })}
                </div>
                <div class="app-card" style="padding:12px;">
                    <div style="display:grid; grid-template-columns:1fr 1fr; gap:10px; font-size:11px;">
                        <div class="app-card" style="padding:8px; margin:0;">
                            <span style="opacity:0.6; display:block;">Eye Shape</span>
                            <strong>Almond</strong>
                        </div>
                        <div class="app-card" style="padding:8px; margin:0;">
                            <span style="opacity:0.6; display:block;">Brow Arch</span>
                            <strong>Soft Arch</strong>
                        </div>
                        <div class="app-card" style="padding:8px; margin:0;">
                            <span style="opacity:0.6; display:block;">Jaw Outline</span>
                            <strong>Tapered</strong>
                        </div>
                        <div class="app-card" style="padding:8px; margin:0;">
                            <span style="opacity:0.6; display:block;">Lip Outline</span>
                            <strong>Full Symmetric</strong>
                        </div>
                    </div>
                </div>
                <button class="app-btn app-btn-primary" onclick="goToScreen(23)">Next: Confidence</button>
            ` + wrapEnd;

        case 23: // AI Confidence Score Screen
            return wrapStart + `
                ${appHeader('Accuracy Matrix')}
                <div class="app-card" style="text-align:center;">
                    <span style="font-size:50px;">🎯</span>
                    <h3 style="font-size:36px; font-weight:700; color:var(--pink-pastel); margin-top:10px;">${state.simulatedConfidence}.4%</h3>
                    <strong style="font-size:14px; display:block; margin-top:6px;">High Accuracy Score</strong>
                    <p style="font-size:12px; opacity:0.7; margin-top:6px;">Scan conditions were optimal with daylight calibration values.</p>
                </div>
                <div class="app-card">
                    <div style="display:flex; justify-content:space-between; margin-bottom:8px; font-size:12px;">
                        <span>Skin analysis confidence</span><strong>98%</strong>
                    </div>
                    <div style="display:flex; justify-content:space-between; font-size:12px;">
                        <span>Shape match confidence</span><strong>94.8%</strong>
                    </div>
                </div>
                <button class="app-btn app-btn-primary" onclick="goToScreen(24)">Next: Report Summary</button>
            ` + wrapEnd;

        case 24: // Summary Report Screen
            return wrapStart + `
                ${appHeader('Report Summary')}
                <div class="app-card" style="padding:14px; margin-bottom:12px;">
                    <h4 style="font-size:12px; font-weight:700; text-transform:uppercase; margin-bottom:8px;">Detected Attributes</h4>
                    <div style="font-size:11px; display:flex; flex-direction:column; gap:6px;">
                        <div style="display:flex; justify-content:space-between;"><span>Skin</span><strong>${state.simulatedSkinType}</strong></div>
                        <div style="display:flex; justify-content:space-between;"><span>Shape</span><strong>${state.simulatedFaceShape}</strong></div>
                        <div style="display:flex; justify-content:space-between;"><span>Confidence</span><strong>${state.simulatedConfidence}%</strong></div>
                    </div>
                </div>
                <div class="app-card" style="padding:14px;">
                    <h4 style="font-size:12px; font-weight:700; text-transform:uppercase; margin-bottom:8px;">Next Action Steps</h4>
                    <p style="font-size:11px; opacity:0.7; line-height:1.4;">Unlock specialized suggestions suited specifically for your facial profiles below.</p>
                </div>
                <div style="display:flex; flex-direction:column; gap:10px; margin-top:16px;">
                    <button class="app-btn app-btn-primary" onclick="goToScreen(26)">Explore Makeup Hacks</button>
                    <button class="app-btn app-btn-secondary" onclick="goToScreen(25)">View Before / After</button>
                </div>
            ` + wrapEnd;

        case 25: // Compare Before/After Screen
            return wrapStart + `
                ${appHeader('Virtual Before / After')}
                <div class="slider-container-screen" style="--slider-pos: ${state.beforeAfterSliderPos}%;">
                    <div class="slider-img before-img">
                        ${getFaceSVG({ tone: state.simulatedSkinTone, hairType: 'waves', lipstick: 'rgba(211, 150, 140, 0.7)', beforeMode: true })}
                        <div style="position:absolute; bottom:10px; left:10px; background:rgba(0,0,0,0.6); color:#fff; font-size:10px; padding:3px 8px; border-radius:4px; z-index:9;">BEFORE</div>
                    </div>
                    <div class="slider-img after-img">
                        ${getFaceSVG({ tone: state.simulatedSkinTone, hairType: 'waves', lipstick: state.simulatedLipstickColor, afterMode: true })}
                        <div style="position:absolute; bottom:10px; right:10px; background:rgba(0,0,0,0.6); color:#fff; font-size:10px; padding:3px 8px; border-radius:4px; z-index:9;">AFTER</div>
                    </div>
                    <div class="slider-bar-line"></div>
                    <div class="slider-handle-circle">↔</div>
                    <input type="range" min="0" max="100" value="${state.beforeAfterSliderPos}" class="slider-control-input" oninput="handleBeforeAfterSlider(this.value)" />
                </div>
                <div class="app-card" style="margin-top:14px; text-align:center;">
                    <p style="font-size:11px; opacity:0.7;">Slide across to check facial differences with simulated foundation layers & color selections.</p>
                </div>
                <button class="app-btn app-btn-primary" onclick="goToScreen(26)">Go to Makeup Hub</button>
            ` + wrapEnd;

        // V. MAKEUP RECOMMENDATION
        case 26: // Makeup Overview Screen
            return wrapStart + `
                ${appHeader('Makeup Matching')}
                <div class="app-card" style="padding: 12px; margin-bottom:12px;">
                    <div style="display:flex; justify-content:space-around; font-size:11px;">
                        <span style="font-weight:600; color:var(--pink-pastel); border-bottom:1.5px solid; padding-bottom:2px; cursor:pointer;">LIPS</span>
                        <span style="cursor:pointer;" onclick="goToScreen(28)">FOUNDATION</span>
                        <span style="cursor:pointer;" onclick="goToScreen(29)">EYES</span>
                    </div>
                </div>

                <div style="display:flex; justify-content:center; height:130px; margin-bottom:12px;">
                    ${currentAvatar()}
                </div>

                <div class="app-card">
                    <h4 style="font-size:11px; font-weight:700; text-transform:uppercase; margin-bottom:8px;">Suggested lipstick</h4>
                    <p style="font-size:11px; opacity:0.7; margin-bottom:12px;">Apply color options matching warmth Undertones.</p>
                    <div style="display:flex; justify-content:space-between; align-items:center;">
                        <button class="app-btn app-btn-outline" style="padding:8px 16px; width:auto;" onclick="goToScreen(27)">Customize Lipsticks</button>
                        <button class="app-btn app-btn-primary" style="padding:8px 16px; width:auto;" onclick="goToScreen(30)">See Full Preview</button>
                    </div>
                </div>
                ${getBottomNavHTML(26)}
            ` + wrapEnd;

        case 27: // Lipstick Shades Recommendation Screen
            return wrapStart + `
                ${appHeader('Lipstick Shades')}
                <div style="display:flex; justify-content:center; height:150px; margin-bottom:12px;">
                    ${getFaceSVG({ tone: state.simulatedSkinTone, hairType: 'bob', lipstick: state.simulatedLipstickColor })}
                </div>
                
                <div class="app-card">
                    <h4 style="font-size:12px; font-weight:700; text-transform:uppercase; margin-bottom:12px;">Lip Color Palette</h4>
                    <div class="color-swatches-row">
                        <div class="shade-bubble ${state.simulatedLipstickColor === '#E25858' ? 'active' : ''}" style="background: #E25858;" onclick="setLipstickColor('#E25858')"></div>
                        <div class="shade-bubble ${state.simulatedLipstickColor === '#D13B76' ? 'active' : ''}" style="background: #D13B76;" onclick="setLipstickColor('#D13B76')"></div>
                        <div class="shade-bubble ${state.simulatedLipstickColor === '#A82D5C' ? 'active' : ''}" style="background: #A82D5C;" onclick="setLipstickColor('#A82D5C')"></div>
                        <div class="shade-bubble ${state.simulatedLipstickColor === '#E07B53' ? 'active' : ''}" style="background: #E07B53;" onclick="setLipstickColor('#E07B53')"></div>
                        <div class="shade-bubble ${state.simulatedLipstickColor === '#B54931' ? 'active' : ''}" style="background: #B54931;" onclick="setLipstickColor('#B54931')"></div>
                    </div>
                    <div style="margin-top:10px; font-size:11px; text-align:center;">
                        Selected: <strong style="color:var(--pink-pastel);">${state.simulatedLipstickColor}</strong>
                    </div>
                </div>
                <button class="app-btn app-btn-primary" onclick="goToScreen(31)">Save Look Bundle</button>
                ${getBottomNavHTML(27)}
            ` + wrapEnd;

        case 28: // Foundation Matching Screen
            return wrapStart + `
                ${appHeader('Foundation Match')}
                <div class="app-card" style="text-align:center;">
                    <span style="font-size:11px; color:var(--gold-accent); font-weight:700;">EXACT SKIN METRIC MATCH</span>
                    <h3 style="font-size:18px; margin-top:4px;">Sand Beige #23</h3>
                    <div style="width:44px; height:44px; border-radius:50%; background:${state.simulatedSkinTone}; margin:8px auto; border:2px solid #fff;"></div>
                    <strong>98.2% Accuracy Match</strong>
                </div>

                <div class="app-card">
                    <h4 style="font-size:12px; font-weight:600; margin-bottom:10px;">Alternate Matches</h4>
                    <div style="display:flex; flex-direction:column; gap:8px; font-size:12px;">
                        <div style="display:flex; justify-content:space-between; border-bottom:1px solid rgba(0,0,0,0.05); padding-bottom:6px;">
                            <span>Matte finish Option</span><strong>Beige Warm (92%)</strong>
                        </div>
                        <div style="display:flex; justify-content:space-between; padding-top:4px;">
                            <span>Brightening tint option</span><strong>Ivory Peach (87%)</strong>
                        </div>
                    </div>
                </div>
                <button class="app-btn app-btn-primary" onclick="goToScreen(29)">Eye Makeup Matches</button>
                ${getBottomNavHTML(28)}
            ` + wrapEnd;

        case 29: // Eye Makeup Styles Screen
            return wrapStart + `
                ${appHeader('Eye Makeup Styles')}
                <div style="display:flex; flex-direction:column; gap:12px;">
                    <div class="app-card" style="display:flex; gap:12px; align-items:center; padding:12px;">
                        <span style="font-size:24px;">👁</span>
                        <div>
                            <h5 style="font-size:13px; font-weight:600;">Sultry Winged Cat-Eye</h5>
                            <p style="font-size:11px; opacity:0.7;">Ideal for Almond eyes. Accentuate lid curves.</p>
                        </div>
                    </div>
                    <div class="app-card" style="display:flex; gap:12px; align-items:center; padding:12px;">
                        <span style="font-size:24px;">🎨</span>
                        <div>
                            <h5 style="font-size:13px; font-weight:600;">Sunset Peach Cut-Crease</h5>
                            <p style="font-size:11px; opacity:0.7;">Blend peach shadows deep across outer crease lines.</p>
                        </div>
                    </div>
                    <div class="app-card" style="display:flex; gap:12px; align-items:center; padding:12px;">
                        <span style="font-size:24px;">✨</span>
                        <div>
                            <h5 style="font-size:13px; font-weight:600;">Glass Dewy Highlights</h5>
                            <p style="font-size:11px; opacity:0.7;">Apply gloss base layers directly onto brow bones.</p>
                        </div>
                    </div>
                </div>
                <button class="app-btn app-btn-primary" style="margin-top:10px;" onclick="goToScreen(30)">See Full Preview</button>
                ${getBottomNavHTML(29)}
            ` + wrapEnd;

        case 30: // Full Makeup Look Preview Screen
            return wrapStart + `
                ${appHeader('Full Makeup Preview')}
                <div style="display:flex; justify-content:center; height:240px; margin-bottom:12px;">
                    ${getFaceSVG({ tone: state.simulatedSkinTone, hairType: 'bob', lipstick: state.simulatedLipstickColor, afterMode: true })}
                </div>
                <div style="display:grid; grid-template-columns:1fr 1fr; gap:12px;">
                    <button class="app-btn app-btn-secondary" onclick="goToScreen(27)">Edit Colors</button>
                    <button class="app-btn app-btn-primary" onclick="goToScreen(31)">Save Complete Look</button>
                </div>
                ${getBottomNavHTML(30)}
            ` + wrapEnd;

        case 31: // Save Makeup Look Screen
            return wrapStart + `
                ${appHeader('Save to Collection')}
                <div class="app-card" style="text-align:center; padding:24px 16px;">
                    <span style="font-size:48px;">📂</span>
                    <h3 style="font-size:18px; margin:12px 0 6px 0;">Look Saved Successfully</h3>
                    <p style="font-size:12px; opacity:0.7;">You catalogued this set under the name:</p>
                    <strong style="color:var(--pink-pastel); font-size:14px; display:block; margin-top:8px;">Summer Glam Palette</strong>
                </div>
                <button class="app-btn app-btn-primary" onclick="goToScreen(47)">View Saved Collection</button>
                ${getBottomNavHTML(31)}
            ` + wrapEnd;

        // VI. SKINCARE RECOMMENDATION
        case 32: // Skincare Routine Screen
            return wrapStart + `
                ${appHeader('Skincare Timeline')}
                <div class="routine-toggle-tabs">
                    <button class="routine-tab-btn ${state.activeSkincareTab === 'am' ? 'active' : ''}" onclick="setSkincareTab('am')">Morning AM</button>
                    <button class="routine-tab-btn ${state.activeSkincareTab === 'pm' ? 'active' : ''}" onclick="setSkincareTab('pm')">Night PM</button>
                </div>

                <div class="timeline-steps">
                    ${state.activeSkincareTab === 'am' ? `
                        <div class="timeline-step-node">
                            <div class="step-details">
                                <h5>Step 1: Hydrating Cleanser</h5>
                                <p>Apply onto damp skin to cleanse without peeling lipids.</p>
                                <span>3 mins</span>
                            </div>
                        </div>
                        <div class="timeline-step-node">
                            <div class="step-details">
                                <h5>Step 2: Niacinamide Serum</h5>
                                <p>Oil regulation target suited for your Oily T-zone.</p>
                                <span>5 mins</span>
                            </div>
                        </div>
                        <div class="timeline-step-node">
                            <div class="step-details">
                                <h5>Step 3: Moisture Veil</h5>
                                <p>Gel-based humectants to keep skin barriers strong.</p>
                                <span>2 mins</span>
                            </div>
                        </div>
                    ` : `
                        <div class="timeline-step-node">
                            <div class="step-details">
                                <h5>Step 1: Cleansing Balm</h5>
                                <p>Dissolves oil-soluble makeup and sunscreen layers.</p>
                                <span>4 mins</span>
                            </div>
                        </div>
                        <div class="timeline-step-node">
                            <div class="step-details">
                                <h5>Step 2: Hyaluronic Acid</h5>
                                <p>Deep skin layer rehydration targeting cheek scales.</p>
                                <span>3 mins</span>
                            </div>
                        </div>
                    `}
                </div>
                <button class="app-btn app-btn-primary" style="margin-top:20px;" onclick="goToScreen(33)">View Products</button>
                ${getBottomNavHTML(32)}
            ` + wrapEnd;

        case 33: // Product Suggestions Screen
            return wrapStart + `
                ${appHeader('Product Matches')}
                <div class="products-scroll-grid">
                    <div class="prod-card">
                        <span class="prod-match-tag">96% Match</span>
                        <div class="prod-img-box">🧴</div>
                        <div class="prod-details">
                            <h6>CeraVe Hydrating</h6>
                            <p>For Dry & Normal skin</p>
                        </div>
                        <div class="prod-price-row"><span>$14.99</span><button class="fav-btn">❤️</button></div>
                    </div>
                    <div class="prod-card">
                        <span class="prod-match-tag">92% Match</span>
                        <div class="prod-img-box">🧪</div>
                        <div class="prod-details">
                            <h6>Ordinary Serum</h6>
                            <p>10% Niacinamide formula</p>
                        </div>
                        <div class="prod-price-row"><span>$6.50</span><button class="fav-btn">🤍</button></div>
                    </div>
                </div>
                <button class="app-btn app-btn-primary" style="margin-top:16px;" onclick="goToScreen(34)">Ingredient Analysis</button>
                ${getBottomNavHTML(33)}
            ` + wrapEnd;

        case 34: // Ingredient Recommendation Screen
            return wrapStart + `
                ${appHeader('Ingredient Targets')}
                <div class="app-card">
                    <h5 style="font-weight:700; color:var(--pink-pastel);">Niacinamide</h5>
                    <p style="font-size:11px; line-height:1.4; margin-top:4px;">Regulates sebum secretions from skin cells. Highly recommended to calm inflammation across detected forehead oily zones.</p>
                </div>
                <div class="app-card">
                    <h5 style="font-weight:700; color:var(--pink-pastel);">Squalane</h5>
                    <p style="font-size:11px; line-height:1.4; margin-top:4px;">Establishes a breathable lipid shield. Perfect to treat dry areas detected on outer cheek structures.</p>
                </div>
                <button class="app-btn app-btn-primary" onclick="goToScreen(35)">Daily Skincare Tips</button>
                ${getBottomNavHTML(34)}
            ` + wrapEnd;

        case 35: // Skin Improvement Tips Screen
            return wrapStart + `
                ${appHeader('Expert Tips')}
                <div class="app-card" style="margin-bottom:12px;">
                    <h5 style="font-weight:600; font-size:13px; margin-bottom:4px;">🌤 UV Defense Rule</h5>
                    <p style="font-size:11px; opacity:0.8; line-height:1.4;">Apply broad spectrum SPF 50 layers daily to prevent moisture leakage.</p>
                </div>
                <div class="app-card" style="margin-bottom:12px;">
                    <h5 style="font-weight:600; font-size:13px; margin-bottom:4px;">💧 Hydration Levels</h5>
                    <p style="font-size:11px; opacity:0.8; line-height:1.4;">Drink 2.5L water daily to flush skin impurities and support tissue elasticity.</p>
                </div>
                <button class="app-btn app-btn-primary" onclick="goToScreen(36)">Moisture Progress Tracking</button>
                ${getBottomNavHTML(35)}
            ` + wrapEnd;

        case 36: // Progress Tracking Screen
            return wrapStart + `
                ${appHeader('Moisture Metrics')}
                <div class="app-card" style="text-align:center;">
                    <span style="font-size:11px; opacity:0.6; text-transform:uppercase;">Moisture over 4 Weeks</span>
                    <!-- Simple SVG line graph showing metric progress -->
                    <svg viewBox="0 0 200 100" style="width:100%; height:110px; margin-top:10px;">
                        <path d="M10,80 Q50,70 90,50 T180,20" fill="none" stroke="var(--pink-pastel)" stroke-width="3"/>
                        <circle cx="10" cy="80" r="4" fill="var(--pink-pastel)"/>
                        <circle cx="90" cy="50" r="4" fill="var(--pink-pastel)"/>
                        <circle cx="180" cy="20" r="4" fill="var(--glow-emerald)"/>
                        <text x="180" y="15" fill="#78E0A0" font-size="8" font-weight="700">82%</text>
                        <text x="10" y="92" fill="currentColor" font-size="8">Wk 1</text>
                        <text x="90" y="92" fill="currentColor" font-size="8">Wk 2</text>
                        <text x="170" y="92" fill="currentColor" font-size="8">Wk 4</text>
                    </svg>
                </div>
                <button class="app-btn app-btn-primary" onclick="goToScreen(37)">Check Hair Matching</button>
                ${getBottomNavHTML(36)}
            ` + wrapEnd;

        // VII. HAIRSTYLE RECOMMENDATION
        case 37: // Hairstyle Suggestions Screen
            return wrapStart + `
                ${appHeader('Hairstyle Matching')}
                <p style="font-size:11px; opacity:0.7; margin-bottom:12px;">Curated style layouts for your detected <strong>${state.simulatedFaceShape}</strong> shape.</p>
                <div style="display:grid; grid-template-columns:1fr 1fr; gap:12px;">
                    <div class="app-card" style="padding:10px; text-align:center; cursor:pointer;" onclick="goToScreen(38)">
                        <span style="font-size:24px;">💇‍♀️</span>
                        <strong style="font-size:12px; display:block; margin-top:6px;">Soft Waves</strong>
                    </div>
                    <div class="app-card" style="padding:10px; text-align:center; cursor:pointer;" onclick="goToScreen(38)">
                        <span style="font-size:24px;">👩</span>
                        <strong style="font-size:12px; display:block; margin-top:6px;">Sleek Bob</strong>
                    </div>
                </div>
                <button class="app-btn app-btn-primary" style="margin-top:20px;" onclick="goToScreen(39)">See Trending Styles</button>
                ${getBottomNavHTML(37)}
            ` + wrapEnd;

        case 38: // Hairstyle Preview on Face Screen
            return wrapStart + `
                ${appHeader('Hairstyle Overlay')}
                <div style="display:flex; justify-content:center; height:220px; margin-bottom:12px;">
                    ${getFaceSVG({ tone: state.simulatedSkinTone, hairType: 'waves', lipstick: state.simulatedLipstickColor, afterMode: true })}
                </div>
                <div class="app-card" style="padding:10px; text-align:center;">
                    <h5 style="font-size:12px; font-weight:600;">Waves overlay active</h5>
                </div>
                <button class="app-btn app-btn-primary" onclick="goToScreen(40)">Save Hairstyle</button>
                ${getBottomNavHTML(38)}
            ` + wrapEnd;

        case 39: // Trending Hairstyles Screen
            return wrapStart + `
                ${appHeader('Trending Styles')}
                <div class="app-card" style="display:flex; gap:12px; align-items:center;">
                    <span style="font-size:32px;">💇‍♀️</span>
                    <div>
                        <h5 style="font-size:13px; font-weight:600;">90s Butterfly Cut</h5>
                        <p style="font-size:11px; opacity:0.7;">Light airy layers framing cheek levels.</p>
                    </div>
                </div>
                <div class="app-card" style="display:flex; gap:12px; align-items:center;">
                    <span style="font-size:32px;">👩</span>
                    <div>
                        <h5 style="font-size:13px; font-weight:600;">Wispy Fringe Pixie</h5>
                        <p style="font-size:11px; opacity:0.7;">Short textured layouts emphasizing brows.</p>
                    </div>
                </div>
                <button class="app-btn app-btn-primary" onclick="goToScreen(40)">Save Choice</button>
                ${getBottomNavHTML(39)}
            ` + wrapEnd;

        case 40: // Save Hairstyle Screen
            return wrapStart + `
                ${appHeader('Style Saved')}
                <div class="app-card" style="text-align:center; padding:30px 10px;">
                    <span style="font-size:40px;">💾</span>
                    <h4 style="font-size:16px; margin-top:12px;">Added to Look Book</h4>
                    <p style="font-size:11px; opacity:0.6; margin-top:6px;">Waves layout saved inside styling vaults.</p>
                </div>
                <button class="app-btn app-btn-primary" onclick="goToScreen(41)">Outfit Analysis</button>
                ${getBottomNavHTML(40)}
            ` + wrapEnd;

        // VIII. OUTFIT & COLOR ANALYSIS
        case 41: // Outfit Color Palette Screen
            return wrapStart + `
                ${appHeader('Color Analysis')}
                <div class="app-card" style="text-align:center;">
                    <span style="font-size:11px; opacity:0.6; text-transform:uppercase;">Seasonal color match</span>
                    <h3 style="font-size:20px; color:var(--pink-pastel); margin:4px 0 10px 0;">Cool Summer Palette</h3>
                    
                    <div style="display:flex; justify-content:center; gap:8px;">
                        <span style="display:block; width:28px; height:28px; border-radius:50%; background:#9BB6C4;"></span>
                        <span style="display:block; width:28px; height:28px; border-radius:50%; background:#E3C2D1;"></span>
                        <span style="display:block; width:28px; height:28px; border-radius:50%; background:#7BA6A8;"></span>
                        <span style="display:block; width:28px; height:28px; border-radius:50%; background:#D5B6A8;"></span>
                    </div>
                </div>
                <button class="app-btn app-btn-primary" onclick="goToScreen(42)">Outfit Formulas</button>
                ${getBottomNavHTML(41)}
            ` + wrapEnd;

        case 42: // Outfit Recommendations Screen
            return wrapStart + `
                ${appHeader('Outfit Recommendations')}
                <div class="app-card">
                    <h5 style="font-size:13px; font-weight:600;">Cozy Neutral Minimalist</h5>
                    <p style="font-size:11px; opacity:0.7; margin-top:4px;">Combine lavender wool coat layers over silk light ivory knits.</p>
                </div>
                <div class="app-card">
                    <h5 style="font-size:13px; font-weight:600;">Pastel Workwear Suit</h5>
                    <p style="font-size:11px; opacity:0.7; margin-top:4px;">Draped powder-blue blazer sets matched with white leather loafers.</p>
                </div>
                <button class="app-btn app-btn-primary" onclick="goToScreen(43)">Seasonal Fashion Ideas</button>
                ${getBottomNavHTML(42)}
            ` + wrapEnd;

        case 43: // Seasonal Fashion Suggestions Screen
            return wrapStart + `
                ${appHeader('Summer Wardrobes')}
                <div style="display:flex; flex-direction:column; gap:12px;">
                    <div class="app-card" style="display:flex; gap:12px; align-items:center;">
                        <span style="font-size:26px;">👒</span>
                        <div>
                            <strong style="font-size:12px; display:block;">Linen Trench</strong>
                            <p style="font-size:10px; opacity:0.7;">Breathable layers matching summer hues.</p>
                        </div>
                    </div>
                    <div class="app-card" style="display:flex; gap:12px; align-items:center;">
                        <span style="font-size:26px;">🕶️</span>
                        <div>
                            <strong style="font-size:12px; display:block;">Gold Oval Glasses</strong>
                            <p style="font-size:10px; opacity:0.7;">Frame balances matches face geometry.</p>
                        </div>
                    </div>
                </div>
                <button class="app-btn app-btn-primary" style="margin-top:10px;" onclick="goToScreen(44)">Go to Mix & Match</button>
                ${getBottomNavHTML(43)}
            ` + wrapEnd;

        case 44: // Mix & Match Screen
            return wrapStart + `
                ${appHeader('Styling Canvas')}
                <div class="mix-match-board">
                    <div class="canvas-slot" data-slot-label="Top Layer">
                        ${state.mixMatchSlots.top ? `<span style="font-size:44px;">${state.mixMatchSlots.top.icon}</span>` : '❓'}
                    </div>
                    <div class="canvas-slot" data-slot-label="Bottom Layer">
                        ${state.mixMatchSlots.bottom ? `<span style="font-size:44px;">${state.mixMatchSlots.bottom.icon}</span>` : '❓'}
                    </div>
                    
                    <div style="font-size:11px; font-weight:600; margin-top:8px;">TAP CLOTHING PIECES TO WEAR:</div>
                    <div class="clothing-options-tray">
                        ${clothingItems.tops.map(item => `
                            <div class="clothing-piece-card ${state.mixMatchSlots.top?.id === item.id ? 'selected' : ''}" onclick="selectMixMatchPiece('top', '${item.id}')">${item.icon}</div>
                        `).join('')}
                        ${clothingItems.bottoms.map(item => `
                            <div class="clothing-piece-card ${state.mixMatchSlots.bottom?.id === item.id ? 'selected' : ''}" onclick="selectMixMatchPiece('bottom', '${item.id}')">${item.icon}</div>
                        `).join('')}
                    </div>
                </div>
                <button class="app-btn app-btn-primary" onclick="goToScreen(45)">Preview Outfit Combination</button>
                ${getBottomNavHTML(44)}
            ` + wrapEnd;

        case 45: // Outfit Preview Screen
            return wrapStart + `
                ${appHeader('Outfit Composition')}
                <div class="app-card" style="text-align:center; height:240px; display:flex; flex-direction:column; justify-content:center; align-items:center;">
                    <div style="font-size:60px;">
                        ${state.mixMatchSlots.top ? state.mixMatchSlots.top.icon : '👚'}
                        ${state.mixMatchSlots.bottom ? state.mixMatchSlots.bottom.icon : '👖'}
                    </div>
                    <h4 style="font-size:14px; margin-top:14px; font-weight:700;">Simulated Outfit Blend</h4>
                    <p style="font-size:11px; opacity:0.6; margin-top:4px;">Matches your cool summer tone profiles.</p>
                </div>
                <button class="app-btn app-btn-primary" onclick="goToScreen(46)">Go to Profile</button>
                ${getBottomNavHTML(45)}
            ` + wrapEnd;

        // IX. USER PROFILE & SETTINGS
        case 46: // Profile Screen
            return wrapStart + `
                <div class="home-welcome" style="margin-top:10px;">
                    <div class="welcome-user">
                        <div class="user-avatar-mini">${currentAvatar()}</div>
                        <div class="welcome-user-text">
                            <h4>Gigi Hadid</h4>
                            <p>Premium VIP Member</p>
                        </div>
                    </div>
                </div>

                <div class="app-card" style="padding:12px;">
                    <div style="display:flex; justify-content:space-around; text-align:center; font-size:11px;">
                        <div><strong>12</strong><br/><span style="opacity:0.6;">Scans Done</span></div>
                        <div style="border-left:1px solid var(--beauty-border-light); border-right:1px solid var(--beauty-border-light); padding:0 20px;"><strong>3</strong><br/><span style="opacity:0.6;">Saved Sets</span></div>
                        <div><strong>Cool</strong><br/><span style="opacity:0.6;">Tone Hue</span></div>
                    </div>
                </div>

                <div style="display:flex; flex-direction:column; gap:10px;">
                    <div class="app-card" style="padding:14px; cursor:pointer;" onclick="goToScreen(47)">
                        <strong>📂 Saved Looks Archive</strong>
                    </div>
                    <div class="app-card" style="padding:14px; cursor:pointer;" onclick="goToScreen(49)">
                        <strong>⚙️ Style Preferences</strong>
                    </div>
                    <div class="app-card" style="padding:14px; cursor:pointer;" onclick="goToScreen(48)">
                        <strong>🛠 Account Settings</strong>
                    </div>
                    <button class="app-btn app-btn-primary" onclick="goToScreen(50)">Premium VIP Upgrades</button>
                </div>
                ${getBottomNavHTML(46)}
            ` + wrapEnd;

        case 47: // Saved Looks Screen
            return wrapStart + `
                ${appHeader('Saved Look Archive')}
                <div style="display:flex; flex-direction:column; gap:10px;">
                    ${state.savedLooks.map(look => `
                        <div class="app-card" style="padding:12px; display:flex; justify-content:space-between; align-items:center;">
                            <div>
                                <span style="font-size:9px; background:rgba(221,183,171,0.2); padding:2px 6px; border-radius:6px; color:var(--pink-pastel); font-weight:700;">${look.type.toUpperCase()}</span>
                                <h5 style="font-size:13px; font-weight:600; margin-top:4px;">${look.name}</h5>
                            </div>
                            <span style="font-size:10px; opacity:0.5;">${look.date}</span>
                        </div>
                    `).join('')}
                </div>
                ${getBottomNavHTML(47)}
            ` + wrapEnd;

        case 48: // Settings Screen
            return wrapStart + `
                ${appHeader('Account Settings')}
                <div class="app-card">
                    <div style="display:flex; justify-content:space-between; align-items:center; border-bottom:1px solid rgba(0,0,0,0.05); padding-bottom:10px;">
                        <span>Push Notifications</span><strong>Active</strong>
                    </div>
                    <div style="display:flex; justify-content:space-between; align-items:center; padding-top:10px;">
                        <span>High Res Camera mode</span><strong>On</strong>
                    </div>
                </div>
                <div class="app-card">
                    <div style="display:flex; justify-content:space-between; align-items:center; border-bottom:1px solid rgba(0,0,0,0.05); padding-bottom:10px;">
                        <span>Terms & Conditions</span><strong>View</strong>
                    </div>
                    <div style="display:flex; justify-content:space-between; align-items:center; padding-top:10px; color:#CA3232; cursor:pointer;" onclick="goToScreen(4)">
                        <span>Logout Account</span><strong>➔</strong>
                    </div>
                </div>
                ${getBottomNavHTML(48)}
            ` + wrapEnd;

        case 49: // Edit Preferences Screen
            return wrapStart + `
                ${appHeader('Edit Style Preferences')}
                <div class="app-card">
                    <h5 style="font-size:12px; margin-bottom:8px;">Target Skin Concerns</h5>
                    <div style="display:flex; flex-direction:column; gap:8px; font-size:12px;">
                        <div><input type="checkbox" id="pref1" checked/> <label for="pref1">Acne Prone Zones</label></div>
                        <div><input type="checkbox" id="pref2"/> <label for="pref2">Fine Wrinkles</label></div>
                        <div><input type="checkbox" id="pref3" checked/> <label for="pref3">Dry Skin Patches</label></div>
                    </div>
                </div>
                <button class="app-btn app-btn-primary" onclick="goToScreen(46)">Save Selection</button>
                ${getBottomNavHTML(49)}
            ` + wrapEnd;

        case 50: // Subscription / Premium VIP Screen
            return wrapStart + `
                ${appHeader('Premium Upgrades')}
                <div class="app-card" style="background:var(--gold-gradient); color:#121216; text-align:center;">
                    <span style="font-size:32px;">👑</span>
                    <h3 style="font-size:20px; font-weight:700;">AI BEAUTY VIP</h3>
                    <p style="font-size:11px; opacity:0.9; margin-top:4px;">Unlock full features: 3D AR hair testing, custom outfit canvases, and dermatologist-tuned AI analysis feeds.</p>
                </div>
                <div style="display:flex; flex-direction:column; gap:10px; margin-top:12px;">
                    <div class="app-card" style="margin:0; display:flex; justify-content:space-between; align-items:center; border:2px solid var(--gold-accent);">
                        <div><strong>Monthly Pass</strong><br/><span style="font-size:11px; opacity:0.6;">All assets unlocked</span></div>
                        <strong>$9.99/mo</strong>
                    </div>
                    <div class="app-card" style="margin:0; display:flex; justify-content:space-between; align-items:center;">
                        <div><strong>Annual Pass</strong><br/><span style="font-size:11px; opacity:0.6;">Save 40% annually</span></div>
                        <strong>$69.99/yr</strong>
                    </div>
                </div>
                <button class="app-btn app-btn-primary" style="margin-top:16px; background:#121216; color:#fff;" onclick="goToScreen(6)">Upgrade Account Now</button>
                ${getBottomNavHTML(50)}
            ` + wrapEnd;

        default:
            return wrapStart + `
                ${appHeader('AI Beauty Genius')}
                <div class="app-card" style="text-align:center;">
                    <h3>Screen ${index}</h3>
                    <p>Visual UI system details matches are active.</p>
                </div>
            ` + wrapEnd;
    }
}

// Generate the bottom navigation menu dynamically with state indicators
function getBottomNavHTML(activeIndex) {
    const isHome = activeIndex === 6;
    const isScan = activeIndex >= 11 && activeIndex <= 18;
    const isExplore = activeIndex >= 26 && activeIndex <= 36;
    const isSaved = activeIndex === 47;
    const isProfile = activeIndex === 46;

    return `
    <nav class="app-bottom-navbar">
        <div class="nav-item ${isHome ? 'active' : ''}" onclick="goToScreen(6)">
            <svg viewBox="0 0 24 24"><path d="M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z"/></svg>
            Home
        </div>
        <div class="nav-item ${isScan ? 'active' : ''}" onclick="goToScreen(12)">
            <svg viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 17h-2v-2h2v2zm2.07-7.75l-.9.92C13.45 12.9 13 13.5 13 15h-2v-.5c0-1.1.45-2.1 1.17-2.83l1.24-1.26c.37-.36.59-.86.59-1.41 0-1.1-.9-2-2-2s-2 .9-2 2H7c0-2.76 2.24-5 5-5s5 2.24 5 5c0 1.04-.42 1.99-1.07 2.75z"/></svg>
            Scan
        </div>
        <div class="nav-item ${isExplore ? 'active' : ''}" onclick="goToScreen(26)">
            <svg viewBox="0 0 24 24"><path d="M12 10.9c-.61 0-1.1.49-1.1 1.1s.49 1.1 1.1 1.1 1.1-.49 1.1-1.1-.49-1.1-1.1-1.1zM12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm2.19 12.19L6 18l3.81-8.19L18 6l-3.81 8.19z"/></svg>
            Explore
        </div>
        <div class="nav-item ${isSaved ? 'active' : ''}" onclick="goToScreen(47)">
            <svg viewBox="0 0 24 24"><path d="M17 3H7c-1.1 0-1.99.9-1.99 2L5 21l7-3 7 3V5c0-1.1-.9-2-2-2z"/></svg>
            Saved
        </div>
        <div class="nav-item ${isProfile ? 'active' : ''}" onclick="goToScreen(46)">
            <svg viewBox="0 0 24 24"><path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/></svg>
            Profile
        </div>
    </nav>
    `;
}

/* ==========================================================================
   NAVIGATION & ACTIONS
   ========================================================================== */
function goToScreen(index) {
    if (index < 1 || index > 50) return;
    
    // Clear scanning timers if active
    if (state.scanInterval) {
        clearInterval(state.scanInterval);
        state.scanInterval = null;
    }
    
    // Clean camera tracking streams
    if (state.cameraStream && index !== 12 && index !== 13) {
        state.cameraStream.getTracks().forEach(track => track.stop());
        state.cameraStream = null;
        state.cameraActive = false;
    }

    state.currentScreenIndex = index;
    
    // Update active indicators inside showcase layouts
    document.querySelectorAll('.screen-links li').forEach(li => {
        li.classList.remove('active');
        if (parseInt(li.getAttribute('data-index')) === index) {
            li.classList.add('active');
            
            // Auto expand folder/category accordion containing the screen
            const parentCard = li.closest('.category-card');
            if (parentCard) {
                parentCard.classList.add('expanded');
            }
        }
    });

    document.getElementById('screen-current-num').textContent = String(index).padStart(2, '0');
    document.getElementById('current-screen-badge').textContent = getScreenNameByIndex(index);
    
    // Update Desktop Header Navigation Visibility and Active state
    const navHeader = document.getElementById('desktop-nav-header');
    if (navHeader) {
        if (index >= 6) {
            navHeader.style.display = 'flex';
            
            // Sync active link styling
            document.querySelectorAll('.desktop-nav-links .nav-link').forEach(link => {
                link.classList.remove('active');
            });
            
            let activeLinkId = '';
            if (index === 6) activeLinkId = 'nav-link-dashboard';
            else if (index >= 11 && index <= 18) activeLinkId = 'nav-link-scan';
            else if (index >= 26 && index <= 31) activeLinkId = 'nav-link-makeup';
            else if (index >= 32 && index <= 36) activeLinkId = 'nav-link-skincare';
            else if (index >= 37 && index <= 40) activeLinkId = 'nav-link-hair';
            else if (index >= 41 && index <= 45) activeLinkId = 'nav-link-outfits';
            else if (index >= 46 && index <= 49) activeLinkId = 'nav-link-profile';
            
            if (activeLinkId) {
                const activeLink = document.getElementById(activeLinkId);
                if (activeLink) activeLink.classList.add('active');
            }
            
            // Sync user avatar indicator inside nav bar
            const navAvatar = document.getElementById('nav-avatar-img');
            if (navAvatar) {
                const tone = state.simulatedSkinTone;
                const lipstick = state.simulatedLipstickColor;
                if (state.simulatedUserAvatar === 'classic-male') {
                    navAvatar.innerHTML = getMaleFaceSVG({ tone });
                } else {
                    navAvatar.innerHTML = getFaceSVG({ tone, hairType: 'bob', lipstick });
                }
            }
        } else {
            navHeader.style.display = 'none';
        }
    }

    // Render the screen viewport
    const viewport = document.getElementById('phone-screen-viewport');
    viewport.innerHTML = getScreenHTML(index);
    
    // Smooth scroll inside web canvas back to top
    viewport.scrollTop = 0;
}

// Translate index to human text for header badge
function getScreenNameByIndex(index) {
    const names = {
        1: 'Splash Screen', 2: 'Onboarding 1', 3: 'Onboarding 2', 4: 'Login Screen', 5: 'Signup Screen',
        6: 'Home Dashboard', 7: 'Bottom Nav UI', 8: 'Notifications', 9: 'Search looks', 10: 'AI Chat Assist',
        11: 'Camera Consent', 12: 'Face Scan Grid', 13: 'Alignment guide', 14: 'AI Contour mapping',
        15: 'Upload Portrait', 16: 'Confirm Portrait', 17: 'Scan analysis progress', 18: 'Scan success',
        19: 'Skin type breakdown', 20: 'Skin tone metrics', 21: 'Face shape wireframe', 22: 'Facial feature points',
        23: 'AI Confidence score', 24: 'Report summary', 25: 'Before / After slider',
        26: 'Makeup Hub overview', 27: 'Lipstick shade select', 28: 'Foundation matching', 29: 'Eye makeup styles',
        30: 'Full makeup look', 31: 'Save looks collection', 32: 'Skincare routine AM/PM', 33: 'Product matches',
        34: 'Ingredient breakdowns', 35: 'Expert skin tips', 36: 'Moisture tracking chart',
        37: 'Hairstyle suggested', 38: 'Hairstyle virtual overlay', 39: 'Trending hair looks', 40: 'Save hairstyles',
        41: 'Seasonal Color Palette', 42: 'Outfit formulas', 43: 'Summer wardrobes', 44: 'Mix & Match canvas',
        45: 'Simulated outfit preview', 46: 'Profile stats', 47: 'Saved Look archive', 48: 'Settings panels',
        49: 'Preferences checklist', 50: 'Premium VIP VIP Upgrade'
    };
    return names[index] || 'Screen ' + index;
}

/* ==========================================================================
   INTERACTIVE FEATURES IMPLEMENTATIONS
   ========================================================================== */

// 1. Camera Initialization
async function initiateCameraScan() {
    try {
        const stream = await navigator.mediaDevices.getUserMedia({ video: { facingMode: 'user', width: 375, height: 600 } });
        state.cameraStream = stream;
        state.cameraActive = true;
        goToScreen(12);
        
        // Wait minor delay to allow camera video DOM attachment
        setTimeout(() => {
            const container = document.getElementById('camera-stream-container');
            if (container) {
                const videoEl = document.createElement('video');
                videoEl.srcObject = stream;
                videoEl.autoplay = true;
                videoEl.playsInline = true;
                videoEl.className = 'camera-stream-fallback';
                container.innerHTML = '';
                container.appendChild(videoEl);
            }
        }, 100);
    } catch (err) {
        console.warn('Webcam not allowed or unavailable. Using simulated avatar.', err);
        goToScreen(12);
    }
}

// 2. Scan Progress simulation with loading increments
function triggerScanProgress() {
    goToScreen(17);
    state.scanPercentage = 0;
    
    const statusTitles = ['RGB light calibrating', 'Scanning skin Undertones', 'Analyzing T-Zone Sebum', 'Mapping Jaw Alignment', 'Finalizing Accuracy'];
    const statusSubs = ['Analyzing camera light balances...', 'Identifying melanin levels...', 'Calculating oil/moisture counts...', 'Checking wireframe dimensions...', 'Compressing metrics data...'];

    state.scanInterval = setInterval(() => {
        state.scanPercentage += 4;
        
        const circleFill = document.getElementById('progress-circle-meter');
        const percentageText = document.getElementById('progress-val-text');
        const statusTitle = document.getElementById('progress-status-title');
        const statusSub = document.getElementById('progress-status-subtitle');

        if (percentageText) percentageText.textContent = `${state.scanPercentage}%`;
        
        if (circleFill) {
            // Stroke dasharray 440 circumference calculation
            const offset = 440 - (440 * state.scanPercentage) / 100;
            circleFill.style.strokeDashoffset = offset;
        }

        // Cycle status messages based on percentage increments
        const phaseIndex = Math.min(statusTitles.length - 1, Math.floor(state.scanPercentage / 20));
        if (statusTitle) statusTitle.textContent = statusTitles[phaseIndex];
        if (statusSub) statusSub.textContent = statusSubs[phaseIndex];

        if (state.scanPercentage >= 100) {
            clearInterval(state.scanInterval);
            state.scanInterval = null;
            goToScreen(18); // Success
        }
    }, 150);
}

// 3. Before/After Split slider control
function handleBeforeAfterSlider(value) {
    state.beforeAfterSliderPos = value;
    document.documentElement.style.setProperty('--slider-pos', `${value}%`);
}

// 4. Skincare AM/PM timeline toggle
function setSkincareTab(tab) {
    state.activeSkincareTab = tab;
    goToScreen(32);
}

// 5. Lipstick shade selector color update
function setLipstickColor(colorHex) {
    state.simulatedLipstickColor = colorHex;
    // Update sandbox inputs
    document.getElementById('sim-lipstick-color').value = colorHex;
    goToScreen(27);
}

// 6. Outfit Mix-Match piece canvas updates
function selectMixMatchPiece(layer, itemId) {
    let selectedPiece = null;
    if (layer === 'top') {
        selectedPiece = clothingItems.tops.find(i => i.id === itemId);
        state.mixMatchSlots.top = selectedPiece;
    } else {
        selectedPiece = clothingItems.bottoms.find(i => i.id === itemId);
        state.mixMatchSlots.bottom = selectedPiece;
    }
    goToScreen(44);
}

// 7. Chat submit action
function submitChatMessage() {
    const input = document.getElementById('chat-message-input');
    if (!input || !input.value.trim()) return;
    
    const userText = input.value.trim();
    state.chatMessages.push({ sender: 'user', text: userText });
    input.value = '';
    
    goToScreen(10);
    
    // Auto scroll chat box down
    setTimeout(() => {
        const historyBox = document.getElementById('chat-history-viewport');
        if (historyBox) historyBox.scrollTop = historyBox.scrollHeight;
    }, 100);

    // AI simulated reply delay
    setTimeout(() => {
        let reply = "That's standard for combination skin types! I recommend utilizing squalane ingredients along cheek regions and avoiding dense pore-blocking oils.";
        if (userText.toLowerCase().includes('lipstick') || userText.toLowerCase().includes('color')) {
            reply = "Coral and warmth terracotta pigments will bring out the golden highlights in your Warm Honey skin profile!";
        }
        state.chatMessages.push({ sender: 'assistant', text: reply });
        goToScreen(10);
        setTimeout(() => {
            const hb = document.getElementById('chat-history-viewport');
            if (hb) hb.scrollTop = hb.scrollHeight;
        }, 100);
    }, 1200);
}

function handleChatSubmit(e) {
    if (e.key === 'Enter') submitChatMessage();
}

/* ==========================================================================
   INITIALIZATION & SETUP EVENTS
   ========================================================================== */
document.addEventListener('DOMContentLoaded', () => {
    // 1. Initial screen viewport render
    goToScreen(1);

    // 2. Setup screen sidebar links clicking
    document.querySelectorAll('.screen-links li').forEach(li => {
        li.addEventListener('click', () => {
            const index = parseInt(li.getAttribute('data-index'));
            goToScreen(index);
        });
    });

    // 3. Setup prev/next control buttons
    document.getElementById('prev-screen-btn').addEventListener('click', () => {
        goToScreen(Math.max(1, state.currentScreenIndex - 1));
    });
    document.getElementById('next-screen-btn').addEventListener('click', () => {
        goToScreen(Math.min(50, state.currentScreenIndex + 1));
    });

    // 4. Setup Control Panel tabs switching
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
            document.querySelectorAll('.tab-pane').forEach(p => p.classList.remove('active'));
            
            btn.classList.add('active');
            const tabId = btn.getAttribute('data-tab');
            document.getElementById(tabId).classList.add('active');
        });
    });

    // 5. Setup screen list accordion triggers
    document.querySelectorAll('.category-header').forEach(header => {
        header.addEventListener('click', () => {
            const card = header.closest('.category-card');
            card.classList.toggle('expanded');
        });
    });

    // 6. Search filtering screen names
    document.getElementById('screen-search').addEventListener('input', (e) => {
        const query = e.target.value.toLowerCase();
        document.querySelectorAll('.screen-links li').forEach(li => {
            const text = li.textContent.toLowerCase();
            if (text.includes(query)) {
                li.style.display = 'flex';
            } else {
                li.style.display = 'none';
            }
        });
    });

    // 7. Sandbox controls updates state listeners
    document.getElementById('sim-skin-type').addEventListener('change', (e) => {
        state.simulatedSkinType = e.target.value;
        if (state.currentScreenIndex === 6 || state.currentScreenIndex === 19 || state.currentScreenIndex === 24) {
            goToScreen(state.currentScreenIndex);
        }
    });

    document.getElementById('sim-skin-tone').addEventListener('input', (e) => {
        state.simulatedSkinTone = e.target.value;
        document.getElementById('sim-skin-tone-label').textContent = `Tone Hex (${e.target.value})`;
        goToScreen(state.currentScreenIndex);
    });

    document.getElementById('sim-face-shape').addEventListener('change', (e) => {
        state.simulatedFaceShape = e.target.value;
        goToScreen(state.currentScreenIndex);
    });

    document.getElementById('sim-user-avatar').addEventListener('change', (e) => {
        state.simulatedUserAvatar = e.target.value;
        goToScreen(state.currentScreenIndex);
    });

    document.getElementById('sim-lipstick-color').addEventListener('input', (e) => {
        state.simulatedLipstickColor = e.target.value;
        goToScreen(state.currentScreenIndex);
    });

    document.getElementById('sim-confidence').addEventListener('input', (e) => {
        state.simulatedConfidence = e.target.value;
        document.getElementById('sim-confidence-val').textContent = e.target.value;
        if (state.currentScreenIndex === 6 || state.currentScreenIndex === 23 || state.currentScreenIndex === 24) {
            goToScreen(state.currentScreenIndex);
        }
    });

    // 8. Showcase theme toggle button
    document.getElementById('theme-toggle-btn').addEventListener('click', () => {
        const body = document.body;
        if (body.classList.contains('showcase-dark')) {
            body.classList.remove('showcase-dark');
            body.classList.add('showcase-light');
            document.getElementById('theme-toggle-btn').innerHTML = '🌙 Dark Mode';
        } else {
            body.classList.remove('showcase-light');
            body.classList.add('showcase-dark');
            document.getElementById('theme-toggle-btn').innerHTML = '☀ Light Mode';
        }
    });

    // 9. Showcase hide control panel (presentation mode)
    document.getElementById('toggle-sidebar-btn').addEventListener('click', () => {
        const sidebar = document.getElementById('control-sidebar');
        sidebar.classList.toggle('hidden');
        
        if (sidebar.classList.contains('hidden')) {
            document.getElementById('toggle-sidebar-btn').innerHTML = '⚙ Review Panel';
        } else {
            document.getElementById('toggle-sidebar-btn').innerHTML = '⚙ Hide Panel';
        }
    });
});

// Expose navigation globally for onclick events inside HTML templates
window.goToScreen = goToScreen;
window.initiateCameraScan = initiateCameraScan;
window.triggerScanProgress = triggerScanProgress;
window.handleBeforeAfterSlider = handleBeforeAfterSlider;
window.setSkincareTab = setSkincareTab;
window.setLipstickColor = setLipstickColor;
window.selectMixMatchPiece = selectMixMatchPiece;
window.submitChatMessage = submitChatMessage;
window.handleChatSubmit = handleChatSubmit;
