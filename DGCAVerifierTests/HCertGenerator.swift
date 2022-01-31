//
//  PayloadGenerator.swift
//  VerificaC19
//
//  Created by Johnny Bueti on 28/01/22.
//

import Foundation
@testable import VerificaC19
@testable import SwiftDGC
import SwiftyJSON

/// Provides helper functions that generate dummy QRCode digital green certificates that carry the provided characteristics, aimed at unit testing.
internal class PayloadGenerator {
	
	/// A manually generated vaccine payload used as base to generate a customizable `HCert`.
	private static let dummyVaccinePayload = "HC1:6BFOXN%TS3DHPVO13J /G-/2YRVA.Q/R82JD2FCJG96V75DOW%IY17EIHY P8L6IWM$S4U45P84HW6U/4:84LC6 YM::QQHIZC4.OI1RM8ZA.A5:S9MKN4NN3F85QNCY0O%0VZ001HOC9JU0D0HT0HB2PL/IB*09B9LW4T*8+DCMH0LDK2%KI*V AQ2%KYZPQV6YP8722XOE7:8IPC2L4U/6H1D31BLOETI0K/4VMA/.6LOE:/8IL882B+SGK*R3T3+7A.N88J4R$F/MAITHW$P7S3-G9++9-G9+E93ZM$96TV6QRR 1JI7JSTNCA7G6MXYQYYQQKRM64YVQB95326FW4AJOMKMV35U:7-Z7QT499RLHPQ15O+4/Z6E 6U963X7$8Q$HMCP63HU$*GT*Q3-Q4+O7F6E%CN4D74DWZJ$7K+ CZEDB2M$9C1QD7+2K3475J%6VAYCSP0VSUY8WU9SG43A-RALVMO8+-VD2PRPTB7S015SSFW/BE1S1EV*2Q396Q*4TVNAZHJ7N471FPL-CA+2KG-6YPPB7C%40F18N4"
	
	/// A manually generated test payload used as base to generate a customizable `HCert`.
	private static let dummyTestPayload = "HC1:6BFOXN%TS3DHPVO13J /G-/2YRVA.Q/R8H:I2FCJG9AE1O/CGJ9-J3P+GY P8L6IWM$S4U45P84HW6U/4:84LC6 YM::QQHIZC4.OI:OIG/Q80PWW2G%89-8CNNM3LO%0WA46+8F/8A.A94LVZ0H*AYZ0MKNAB5S.8%*8Z95NEL6T98VA8YISLV423VLJ0JBIFT/1541TS+0C4TV*C*K5-ZVMHFIFT.HBC77PM5LXK$4JSZ4P:45/GK%I74J9.SXTC69TQ0SG JK423UJ*IBLOIWHSJZI+EBI.CHFTQMCA.SF*SSMCU3TNQ4TR9Y$H5%HTR9C/P0Q3%*JMY54W1XYH9W1OH6NFEYY57Q4UYQD*O%+Q.SQBDO3KLB75EHPSGO0IQOGOE34L/5R3FOKEH-BK2L88LNUMD78*7LMIAK/BGP95MG/IC3DAF:F6LF7E9Y7M-CI73A3 9-QDSRD1PC6LFE1KEJC%:CMNSQ98N:21 2O*4R60NM8JI0EUGP$I/XK$M8ZQE6YB9M66P8N31TMC3FD5I7NZLDMOCY7H6UPC9A7I*-E Y7-XPZP5CWQXAUHO6O5M1-V1ENE*N +2:ONETEKTFV5ENQMHZF.+E:OUL4NLEQY$HPMGP2G/20165T1"
	
	/// A manually generated recovery payload used as base to generate a customizable `HCert`.
	private static let dummyRecoveryPayload = "HC1:6BFOXN%TS3DHPVO13J /G-/2YRVA.Q/R8WRU2FCAH9BDF%188WA.*RXU7IJ6W*PP+PDPIGOK-*GN*Q:XJR-GM%O-RQOTAF/8X*G3M9FQH+4J/-K$+CY73JC3MD3IFTKJ3SZ4P:45/GZW4:.AY731MF7FN6LBHKBCAJPF71M3.FJZIJ09B*KNQ579PJMD3+476J3:NB3N5XW49+20CMAHLW 70SO:GOLIROGOAQ5ZU4RKCSHGX2M5C9HHB%LGJZII7JSTNCA7G6MXYQYYQQKRM64YVQB95326FW4AJOMKMV35U:7-Z7QT499RLHPQ15O+4/Z6E 6U963X7$8Q$HMCP63HU$*GT*Q3-Q4+O7F6E%CN4D74DWZJ$7K+ CZEDB2M$9C1QD7+2*KUQFCOYA73A-MG*VM%UUY$MW5LM+GW*1.Q5$Y7M-FSYLJF3*TRJY9R.8VBQA65%UVLXFTYVN T$WM3 UJ16F:S0CLRVJAD7KOB1GV+20RT8S0"
	
	/// A manually generated revocation payload used as base to generate a customizable `HCert`.
	/// It internally returns the dummy vaccine payload.
	private static var dummyRevocationPayload: String {
		return self.dummyVaccinePayload
	}
	
	/// A customizable `HCert` generated from the dummy base payload.
	private static var dummyHCert: HCert {
		var hcert: HCert? 		= HCert(from: self.dummyVaccinePayload)
		let bodyString: String 	= "{\"4\": 1628553600, \"6\": 1620926082, \"1\": \"Ministero della Salute\", \"-260\": {\"1\": {\"ver\": \"1.0.0\", \"dob\": \"1977-06-16\", \"v\": [{\"ma\": \"ORG-100030215\", \"sd\": 2, \"dt\": \"2021-06-08\", \"co\": \"IT\", \"ci\": \"01IT67DA8332EF2C4E6780ABA5DF078A018E#0\", \"mp\": \"EU/1/20/1528\", \"is\": \"Ministero della Salute\", \"tg\": \"840539006\", \"vp\": \"1119349007\", \"dn\": 2}], \"nam\": {\"gnt\": \"MARILU<TERESA\", \"gn\": \"Marilù Teresa\", \"fn\": \"Di Caprio\", \"fnt\": \"DI<CAPRIO\"}}}}"
		hcert!.body = JSON(parseJSON: bodyString)[ClaimKey.hCert.rawValue][ClaimKey.euDgcV1.rawValue]
		return hcert!
	}
	
}

/// Identifies a specific `HCert` type.
internal enum HCertType {
	case vaccine
	case test
	case recovery
	case revocation
}
