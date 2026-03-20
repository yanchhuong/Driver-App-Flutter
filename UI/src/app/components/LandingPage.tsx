import { Car, DollarSign, Clock, Shield, TrendingUp, MapPin } from 'lucide-react';

interface LandingPageProps {
  onGetStarted: () => void;
  onSignIn: () => void;
}

export function LandingPage({ onGetStarted, onSignIn }: LandingPageProps) {
  const features = [
    {
      icon: DollarSign,
      title: 'Earn More',
      description: 'Set your own schedule and maximize your earnings'
    },
    {
      icon: Clock,
      title: 'Flexible Hours',
      description: 'Drive when you want, as much as you want'
    },
    {
      icon: Shield,
      title: 'Safe & Secure',
      description: '24/7 support and insurance coverage'
    },
    {
      icon: TrendingUp,
      title: 'Weekly Payouts',
      description: 'Get paid weekly directly to your account'
    }
  ];

  return (
    <div className="min-h-screen bg-gradient-to-b from-blue-600 to-blue-800 text-white">
      {/* Hero Section */}
      <div className="relative overflow-hidden">
        {/* Background Pattern */}
        <div className="absolute inset-0 opacity-10">
          <div className="absolute top-20 left-10 w-64 h-64 bg-white rounded-full blur-3xl"></div>
          <div className="absolute bottom-20 right-10 w-72 h-72 bg-white rounded-full blur-3xl"></div>
        </div>

        <div className="relative px-4 pt-8 pb-12">
          {/* Logo */}
          <div className="flex items-center gap-2 mb-12">
            <div className="bg-white rounded-full p-2">
              <Car className="w-5 h-5 text-blue-600" />
            </div>
            <span className="text-lg font-bold">DriveApp</span>
          </div>

          {/* Hero Content */}
          <div className="max-w-lg mx-auto text-center space-y-4">
            <h1 className="text-3xl font-bold leading-tight">
              Drive. Earn.
              <br />
              <span className="text-blue-200">Live Life on Your Terms</span>
            </h1>
            <p className="text-base text-blue-100 px-4">
              Join thousands of drivers earning great money with flexible hours. Start your journey today.
            </p>

            {/* CTA Buttons */}
            <div className="flex flex-col gap-3 pt-6 px-4">
              <button
                onClick={onGetStarted}
                className="w-full bg-white text-blue-600 py-4 px-6 rounded-full font-semibold hover:bg-blue-50 active:bg-blue-100 transition-all shadow-lg"
              >
                Get Started
              </button>
              <button
                onClick={onSignIn}
                className="w-full bg-transparent border-2 border-white text-white py-4 px-6 rounded-full font-semibold hover:bg-white/10 active:bg-white/20 transition-all"
              >
                Sign In
              </button>
            </div>
          </div>

          {/* Illustration/Visual Element */}
          <div className="mt-12 flex justify-center px-4">
            <div className="relative">
              <div className="bg-white/10 backdrop-blur-sm rounded-3xl p-6 border border-white/20">
                <Car className="w-24 h-24 text-white/90" />
              </div>
              {/* Floating Elements */}
              <div className="absolute -top-3 -right-3 bg-green-400 text-green-900 px-3 py-1.5 rounded-full font-semibold text-xs shadow-lg flex items-center gap-1">
                <DollarSign className="w-3 h-3" />
                Earn More
              </div>
              <div className="absolute -bottom-2 -left-3 bg-yellow-400 text-yellow-900 px-3 py-1.5 rounded-full font-semibold text-xs shadow-lg flex items-center gap-1">
                <Clock className="w-3 h-3" />
                Flexible
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Features Section */}
      <div className="bg-white text-gray-900 px-4 py-12">
        <div className="max-w-lg mx-auto">
          <div className="text-center mb-8">
            <h2 className="text-2xl font-bold mb-2">Why Drive With Us?</h2>
            <p className="text-gray-600 text-sm">Everything you need to succeed on the road</p>
          </div>

          <div className="grid grid-cols-1 gap-4">
            {features.map((feature, index) => (
              <div
                key={index}
                className="bg-gray-50 rounded-2xl p-4 hover:shadow-lg transition-shadow"
              >
                <div className="flex items-start gap-3">
                  <div className="bg-blue-100 text-blue-600 p-2.5 rounded-xl flex-shrink-0">
                    <feature.icon className="w-5 h-5" />
                  </div>
                  <div>
                    <h3 className="font-semibold text-base mb-0.5">{feature.title}</h3>
                    <p className="text-gray-600 text-sm">{feature.description}</p>
                  </div>
                </div>
              </div>
            ))}
          </div>

          {/* Stats Section */}
          <div className="mt-12 grid grid-cols-3 gap-3 text-center">
            <div className="bg-gradient-to-br from-blue-50 to-blue-100 rounded-2xl p-4">
              <div className="text-2xl font-bold text-blue-600 mb-0.5">50K+</div>
              <div className="text-xs text-gray-600">Active Drivers</div>
            </div>
            <div className="bg-gradient-to-br from-green-50 to-green-100 rounded-2xl p-4">
              <div className="text-2xl font-bold text-green-600 mb-0.5">$2.5K</div>
              <div className="text-xs text-gray-600">Avg. Weekly</div>
            </div>
            <div className="bg-gradient-to-br from-purple-50 to-purple-100 rounded-2xl p-4">
              <div className="text-2xl font-bold text-purple-600 mb-0.5">4.8★</div>
              <div className="text-xs text-gray-600">Driver Rating</div>
            </div>
          </div>

          {/* Bottom CTA */}
          <div className="mt-12 text-center bg-gradient-to-r from-blue-600 to-blue-700 rounded-3xl p-6 text-white">
            <h3 className="text-xl font-bold mb-2">Ready to Start Earning?</h3>
            <p className="text-blue-100 text-sm mb-5">
              Sign up today and start your first ride within 24 hours
            </p>
            <button
              onClick={onGetStarted}
              className="bg-white text-blue-600 py-3 px-6 rounded-full font-semibold hover:bg-blue-50 active:bg-blue-100 transition-all shadow-lg inline-flex items-center gap-2"
            >
              <MapPin className="w-4 h-4" />
              Start Driving Now
            </button>
          </div>
        </div>
      </div>

      {/* Footer */}
      <div className="bg-gray-900 text-gray-400 px-4 py-6 text-center text-xs">
        <p>© 2026 DriveApp. All rights reserved.</p>
        <div className="flex justify-center gap-6 mt-3">
          <button className="hover:text-white transition-colors">Terms</button>
          <button className="hover:text-white transition-colors">Privacy</button>
          <button className="hover:text-white transition-colors">Support</button>
        </div>
      </div>
    </div>
  );
}